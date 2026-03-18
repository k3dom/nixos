{
  pkgs,
  inputs,
  system,
  homeStateVersion,
  user,
  hostName,
  ...
}: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.default
    (final: prev: {
      git-wt = prev.buildGoModule rec {
        pname = "git-wt";
        version = "0.25.0";

        src = prev.fetchFromGitHub {
          owner = "k1LoW";
          repo = "git-wt";
          tag = "v${version}";
          hash = "sha256-QdyONDVokpOaH5dI5v1rmaymCgIiWZ16h26FAIsAHPc=";
        };

        vendorHash = "sha256-O4vqouNxvA3GvrnpRO6GXDD8ysPfFCaaSJVFj2ufxwI=";

        nativeCheckInputs = [ prev.git ];

        ldflags = [
          "-s"
          "-w"
          "-X github.com/k1LoW/git-wt/version.Version=v${version}"
        ];

        meta = {
          description = "Git subcommand that makes git worktree simple";
          homepage = "https://github.com/k1LoW/git-wt";
          changelog = "https://github.com/k1LoW/git-wt/releases/tag/v${version}";
          license = prev.lib.licenses.mit;
          maintainers = with prev.lib.maintainers; [ ryoppippi ];
          mainProgram = "git-wt";
        };
      };
    })
    (final: prev: {
      gnomeExtensions =
        prev.gnomeExtensions
        // {
          tailscale-qs = prev.gnomeExtensions.tailscale-qs.overrideAttrs (oldAttrs: {
            version = "49-unstable";
            src = "${inputs.tailscale-gnome-qs}/tailscale@joaophi.github.com";
          });
        };
      vite-plus = final.callPackage ../../pkgs/vite-plus {};
    })
  ];
  home-manager = {
    users.${user} = import ./home.nix;
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit
        inputs
        system
        homeStateVersion
        user
        hostName
        ;
    };
  };
  programs = {
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 15d --keep 3";
      };
      flake = "/home/${user}/nixos";
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
      ];
    };
  };
}
