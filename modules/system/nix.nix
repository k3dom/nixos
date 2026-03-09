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
      gnomeExtensions =
        prev.gnomeExtensions
        // {
          tailscale-qs = prev.gnomeExtensions.tailscale-qs.overrideAttrs (oldAttrs: {
            version = "49-unstable";
            src = "${inputs.tailscale-gnome-qs}/tailscale@joaophi.github.com";
          });
        };
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
