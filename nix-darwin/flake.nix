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
            inputs.nix-packages.darwinModules.lite-xl-app
            ./flake-nixpkgs.nix
            ./flake-darwin.nix
            home-manager.darwinModules.home-manager
            ./flake-home.nix
            inputs.brew-nix-extra.darwinModules.google-chrome
            inputs.brew-nix-extra.darwinModules.motrix-next
            inputs.brew-nix-extra.darwinModules.wetype
            inputs.brew-nix-extra.darwinModules.neteasemusic
            ./flake-brew.nix
            ./flake-mas.nix
          ];
        };
      };
    };
}
