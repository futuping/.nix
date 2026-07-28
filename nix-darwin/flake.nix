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

    brew-api-extra = {
      url = "github:futuping/brew-api-extra";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      ...
    }:
    let
      machine = rec {
        hostName = "MacBook-Pro";
        system = "aarch64-darwin";
        userName = "level";
        homeDirectory = "/Users/${userName}";
        configurationDirectory = "${homeDirectory}/.nix";
      };
    in
    {
      darwinConfigurations = {
        ${machine.hostName} = nix-darwin.lib.darwinSystem {
          system = machine.system;

          specialArgs = {
            inherit inputs machine self;
          };

          modules = [
            ./flake-darwin.nix
            ./flake-brew.nix
            ./flake-wetype.nix
            ./flake-mas.nix
            ./flake-fonts.nix
          ];
        };
      };
    };
}
