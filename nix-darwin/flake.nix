{
  description = "Modular Darwin system configuration with Homebrew integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.brew-api.follows = "brew-api";
    };

    brew-nix-extra = {
      url = "github:futuping/brew-nix-extra";
      inputs.brew-nix.follows = "brew-nix";
      inputs.brew-api-extra.follows = "brew-api-extra";
    };

    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };

    brew-api-extra = {
      url = "github:futuping/brew-api-extra";
      flake = false;
    };

    nix-packages = {
      url = "github:futuping/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
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
            # System and package sources
            ./nix-packages.nix
            ./flake-nixpkgs.nix
            ./flake-darwin.nix

            # User environment
            home-manager.darwinModules.home-manager
            ./flake-home.nix

            # Application integrations
            ./flake-brew.nix
            ./flake-mas.nix
          ];
        };
      };
    };
}
