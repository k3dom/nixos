{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        fish_vi_key_bindings
        git wt --init fish | source

        function git-wt-fzf
          set -l worktree (git-wt | fzf --header-lines=1 | awk '{if ($1 == "*") print $2; else print $1}')
          if test -n "$worktree"
            cd "$worktree"
          end
        end

        bind -M insert \cf accept-autosuggestion
        bind -M insert \cr history-pager

        abbr -a k   "kubectl"
        abbr -a kn  "kubens"
        abbr -a kc  "kubectx"
        abbr -a oc  "opencode"
        abbr -a cc  "CLAUDE_CODE_NO_FLICKER=1 claude --dangerously-skip-permissions"
        abbr -a g   "git"
        abbr -a gwt "git-wt-fzf"
      '';
    };
    # Disable slow generation of man caches that fish enables automatically
    # via the `documentation.man.generateCaches` option.
    man.generateCaches = false;
  };
}
