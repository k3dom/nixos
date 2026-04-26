{
  pkgs,
  inputs,
  system,
  homeStateVersion,
  user,
  hostName,
  ...
}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
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
      flake = "/home/${user}/nixos";
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.llm-agents.overlays.default
    (final: prev: {
      dsnote = prev.callPackage ../../pkgs/dsnote/package.nix {
        rhvoice = prev.rhvoice.overrideAttrs (oldAttrs: {
          postPatch =
            (oldAttrs.postPatch or "")
            + ''
              sed -i '/#include "audio.hpp"/i #include <cstdint>' src/audio/playback_stream_impl.hpp
            '';
        });
      };

      git-wt = prev.buildGoModule rec {
        pname = "git-wt";
        version = "0.27.0";

        src = prev.fetchFromGitHub {
          owner = "k1LoW";
          repo = "git-wt";
          tag = "v${version}";
          hash = "sha256-oGY9uMqP/hlIG9p/JaVqoBaxI7VFDIEIlwP5rBa3Diw=";
        };

        vendorHash = "sha256-4ak2Gx/i/yvj/tAoDJjsfpBUKJI5iDyKIuv7R7Pzz/w=";

        nativeCheckInputs = [prev.git];

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
          maintainers = with prev.lib.maintainers; [ryoppippi];
          mainProgram = "git-wt";
        };
      };

      gnomeExtensions =
        prev.gnomeExtensions
        // {
          tailscale-qs = prev.stdenv.mkDerivation {
            pname = "gnome-shell-extension-tailscale-qs";
            version = "5";

            src = prev.fetchFromGitHub {
              owner = "tailscale-qs";
              repo = "tailscale-gnome-qs";
              rev = "2de39e9184725944c3bf9edafd28637c669303b5";
              hash = "sha256-NIcbBEIilQX8vvsi+0VDIzq3QGgTYJEHyMyupN9PdNY=";
            };

            nativeBuildInputs = [prev.glib];

            buildPhase = ''
              runHook preBuild
              if [ -d tailscale-gnome-qs@tailscale-qs.github.io/schemas ]; then
                glib-compile-schemas --strict tailscale-gnome-qs@tailscale-qs.github.io/schemas
              fi
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/share/gnome-shell/extensions/
              cp -r tailscale-gnome-qs@tailscale-qs.github.io \
                $out/share/gnome-shell/extensions/tailscale-gnome-qs@tailscale-qs.github.io
              runHook postInstall
            '';

            passthru = {
              extensionUuid = "tailscale-gnome-qs@tailscale-qs.github.io";
              extensionPortalSlug = "tailscale-qs";
            };

            meta = {
              description = "Add Tailscale to GNOME quick settings";
              homepage = "https://github.com/tailscale-qs/tailscale-gnome-qs";
              license = prev.lib.licenses.gpl3Plus;
            };
          };
        };
    })
  ];
}
