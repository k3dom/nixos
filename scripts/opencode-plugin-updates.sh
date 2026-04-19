#!/usr/bin/env bash

set -euo pipefail

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  c_reset=$'\033[0m'
  c_dim=$'\033[2m'
  c_bold=$'\033[1m'
  c_red=$'\033[31m'
  c_green=$'\033[32m'
  c_yellow=$'\033[33m'
  c_blue=$'\033[34m'
  c_magenta=$'\033[35m'
  c_cyan=$'\033[36m'
else
  c_reset=
  c_dim=
  c_bold=
  c_red=
  c_green=
  c_yellow=
  c_blue=
  c_magenta=
  c_cyan=
fi

usage() {
  cat <<'EOF'
Usage: opencode-plugin-updates.sh [--file PATH] [--yes] [--dry-run]

Checks the opencode plugins pinned in modules/home/agents.nix against the
GitHub repositories commented directly above them, shows the newer releases,
and optionally updates the pinned version strings in place.

Options:
  --file PATH  Use a different agents.nix file
  --yes        Apply all available updates without prompting
  --dry-run    Show available updates without editing the file
  -h, --help   Show this help text
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

normalize_version() {
  printf '%s\n' "${1#v}"
}

version_gt() {
  local left right highest

  left="$(normalize_version "$1")"
  right="$(normalize_version "$2")"
  highest="$(printf '%s\n%s\n' "$left" "$right" | sort -V | tail -n1)"

  [[ "$left" == "$highest" && "$left" != "$right" ]]
}

github_api_get() {
  local url=$1
  local headers=()

  headers+=("-H" "Accept: application/vnd.github+json")
  headers+=("-H" "X-GitHub-Api-Version: 2022-11-28")

  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    headers+=("-H" "Authorization: Bearer ${GITHUB_TOKEN}")
  elif [[ -n "${GH_TOKEN:-}" ]]; then
    headers+=("-H" "Authorization: Bearer ${GH_TOKEN}")
  fi

  curl -fsSL "${headers[@]}" "$url"
}

print_release_notes() {
  local notes=$1

  if [[ -z "$notes" || "$notes" == "null" ]]; then
    printf '    No release notes provided.\n'
    return
  fi

  while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      continue
    fi
    printf '    %s\n' "$line"
  done <<< "$notes"
}

apply_version_update() {
  local file=$1
  local plugin=$2
  local current_version=$3
  local next_version=$4

  PLUGIN_NAME="$plugin" CURRENT_VERSION="$current_version" NEXT_VERSION="$next_version" perl -0pi -e '
    my $plugin = quotemeta($ENV{PLUGIN_NAME});
    my $next = $ENV{NEXT_VERSION};
    my $updated = s/("$plugin\@)[^"]+(")/$1$next$2/g;
    die "Could not find pinned version for $ENV{PLUGIN_NAME}\n" if !$updated;
  ' "$file"
}

script_dir=$(realpath "$(dirname "$0")")
repo_root=$(git -C "$script_dir/.." rev-parse --show-toplevel 2>/dev/null || realpath "$script_dir/..")

agents_file="$repo_root/modules/home/agents.nix"
auto_yes=false
dry_run=false

while (($# > 0)); do
  case "$1" in
    --file)
      if (($# < 2)); then
        printf '%s requires a path\n\n' "$1" >&2
        usage >&2
        exit 1
      fi
      agents_file=$2
      shift 2
      ;;
    --yes)
      auto_yes=true
      shift
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd curl
require_cmd jq
require_cmd perl
require_cmd sort
require_cmd tail

if [[ ! -f "$agents_file" ]]; then
  printf 'agents.nix not found: %s\n' "$agents_file" >&2
  exit 1
fi

pending_repo=
declare -a plugin_names=()
declare -a plugin_versions=()
declare -a plugin_repos=()

while IFS= read -r line; do
  if [[ $line =~ ^[[:space:]]*#[[:space:]]*https://github\.com/([^[:space:]]+) ]]; then
    pending_repo=${BASH_REMATCH[1]}
    continue
  fi

  if [[ $line =~ \"([^\"]+)@([^\"]+)\" ]]; then
    if [[ -z "$pending_repo" ]]; then
      continue
    fi

    plugin_names+=("${BASH_REMATCH[1]}")
    plugin_versions+=("${BASH_REMATCH[2]}")
    plugin_repos+=("$pending_repo")
    pending_repo=
  fi
done < "$agents_file"

if ((${#plugin_names[@]} == 0)); then
  printf 'No plugins with GitHub repository comments found in %s\n' "$agents_file" >&2
  exit 1
fi

printf 'Scanning %s\n' "$agents_file"

updates_found=0
updates_applied=0

for i in "${!plugin_names[@]}"; do
  plugin=${plugin_names[$i]}
  pinned_version=${plugin_versions[$i]}
  repo=${plugin_repos[$i]}
  pinned_normalized=$(normalize_version "$pinned_version")

  printf '\n%s%s%s\n' "$c_dim" "============================================================" "$c_reset"
  printf '%sPlugin:%s %s\n' "$c_bold" "$c_reset" "$plugin"
  printf '%sRepo:%s   %s%s%s\n' "$c_bold" "$c_reset" "$c_cyan" "$repo" "$c_reset"
  printf '%sPinned:%s %s%s%s\n' "$c_bold" "$c_reset" "$c_magenta" "$pinned_version" "$c_reset"

  release_json=$(mktemp)
  if ! github_api_get "https://api.github.com/repos/$repo/releases?per_page=100" > "$release_json"; then
    rm -f "$release_json"
    printf 'Status: Failed to fetch releases from GitHub\n' >&2
    continue
  fi

  mapfile -t releases < <(jq -c '.[] | select(.draft == false and .prerelease == false)' "$release_json")
  rm -f "$release_json"

  if ((${#releases[@]} == 0)); then
    printf 'Status: No published releases found\n'
    continue
  fi

  latest_tag=$(jq -r '.tag_name' <<< "${releases[0]}")
  latest_version=$(normalize_version "$latest_tag")

  if ! version_gt "$latest_version" "$pinned_version"; then
    printf '%sLatest:%s %s%s%s\n' "$c_bold" "$c_reset" "$c_green" "$latest_version" "$c_reset"
    if version_gt "$pinned_version" "$latest_version"; then
      printf '%sStatus:%s %sPinned version is newer than the latest GitHub release%s\n' "$c_bold" "$c_reset" "$c_yellow" "$c_reset"
    else
      printf '%sStatus:%s %sAlready up to date%s\n' "$c_bold" "$c_reset" "$c_green" "$c_reset"
    fi
    continue
  fi

  updates_found=$((updates_found + 1))
  printf '%sLatest:%s %s%s%s\n' "$c_bold" "$c_reset" "$c_green" "$latest_version" "$c_reset"
  printf '%sStatus:%s %sUpdate available%s\n' "$c_bold" "$c_reset" "$c_yellow" "$c_reset"
  printf '%sReleases since %s:%s\n' "$c_bold" "$pinned_version" "$c_reset"

  declare -a newer_releases=()
  for release in "${releases[@]}"; do
    tag=$(jq -r '.tag_name' <<< "$release")
    normalized_tag=$(normalize_version "$tag")

    if [[ "$normalized_tag" == "$pinned_normalized" ]]; then
      break
    fi

    if version_gt "$normalized_tag" "$pinned_version"; then
      newer_releases+=("$release")
    fi
  done

  for release in "${newer_releases[@]}"; do
    tag=$(jq -r '.tag_name' <<< "$release")
    name=$(jq -r '.name // empty' <<< "$release")
    published_at=$(jq -r '.published_at // empty' <<< "$release")
    published_date=${published_at%%T*}
    html_url=$(jq -r '.html_url // empty' <<< "$release")
    body=$(jq -r '.body // empty' <<< "$release")

    printf '\n  %s%s%s' "$c_blue" "$tag" "$c_reset"
    if [[ -n "$name" && "$name" != "$tag" ]]; then
      printf '  %s%s%s' "$c_bold" "$name" "$c_reset"
    fi
    if [[ -n "$published_date" ]]; then
      printf '  %s(%s)%s' "$c_dim" "$published_date" "$c_reset"
    fi
    printf '\n'

    if [[ -n "$html_url" ]]; then
      printf '    %s%s%s\n' "$c_cyan" "$html_url" "$c_reset"
    fi

    print_release_notes "$body"
  done

  should_apply=false
  if [[ "$dry_run" == true ]]; then
    printf '\n%sDry run:%s skipping file update\n' "$c_bold" "$c_reset"
    continue
  fi

  if [[ "$auto_yes" == true ]]; then
    should_apply=true
  else
    read -r -p $'\nUpdate pinned version in '"$agents_file"$'? [y/N] ' reply
    if [[ $reply =~ ^([yY]|[yY][eE][sS])$ ]]; then
      should_apply=true
    fi
  fi

  if [[ "$should_apply" == true ]]; then
    apply_version_update "$agents_file" "$plugin" "$pinned_version" "$latest_version"
    updates_applied=$((updates_applied + 1))
    printf '%sUpdated %s:%s %s%s%s -> %s%s%s\n' "$c_green" "$plugin" "$c_reset" "$c_magenta" "$pinned_version" "$c_reset" "$c_green" "$latest_version" "$c_reset"
  else
    printf '%sSkipped%s %s\n' "$c_yellow" "$c_reset" "$plugin"
  fi
done

printf '\n%s%s%s\n' "$c_dim" "============================================================" "$c_reset"
if ((updates_found == 0)); then
  printf '%sAll tracked opencode plugins are already up to date.%s\n' "$c_green" "$c_reset"
else
  printf '%sUpdates found:%s   %d\n' "$c_bold" "$c_reset" "$updates_found"
  printf '%sUpdates applied:%s %d\n' "$c_bold" "$c_reset" "$updates_applied"
  if [[ "$dry_run" == true ]]; then
    printf '%sNo files were modified because --dry-run was used.%s\n' "$c_dim" "$c_reset"
  fi
fi
