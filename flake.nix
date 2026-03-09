{
  description = "NixOS configuration of kedom";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim = {
      url = "github:kedom1337/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tailscale-gnome-qs = {
      url = "github:aoiwelle/tailscale-gnome-qs/fix-gnome-49";
      flake = false;
    };
  };
  outputs = {
    nixpkgs,
    flake-utils,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    user = "kedom";
    homeStateVersion = "26.05";
    hosts = [
      {
        hostName = "t480";
        stateVersion = "26.05";
      }
      {
        hostName = "desktop";
        stateVersion = "26.05";
      }
    ];
    mkHost = host: {
      name = host.hostName;
      value = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs system homeStateVersion user;
          inherit (host) hostName stateVersion;
        };
        modules = [
          home-manager.nixosModules.default
          ./hosts/${host.hostName}/configuration.nix
        ];
      };
    };
  in
    {
      nixosConfigurations = builtins.listToAttrs (map mkHost hosts);
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            statix
          ];
        };
        formatter = pkgs.alejandra;
      }
    );
}
