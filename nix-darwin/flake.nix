{
  description = "Modular Darwin system configuration with Homebrew integration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.brew-api.follows = "brew-api";
    };

    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      brew-nix,
      brew-api,
      ...
    }:
    {
      darwinConfigurations = {
        "MacBook-Pro" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          specialArgs = {
            inherit inputs self;
          };

          modules = [
            ./flake-darwin.nix
            ./flake-brew.nix
            ./flake-mas.nix
            ./flake-fonts.nix
          ];
        };
      };
    };
}
