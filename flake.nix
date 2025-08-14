{
  description = "Darwin system configuration flake for macOS";

  # ============================================================================
  # INPUTS
  # ============================================================================
  inputs = {
    # Main nixpkgs repository - using unstable for latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin for macOS system management
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";  # Use same nixpkgs version
    };

    # brew-nix for Homebrew integration
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.brew-api.follows = "brew-api";
    };

    # brew-api for Homebrew package definitions
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
  };

  # ============================================================================
  # OUTPUTS
  # ============================================================================
  outputs = inputs@{ self, nixpkgs, nix-darwin, brew-nix, brew-api, ... }: {
    # Darwin system configuration for MacBook-Air
    darwinConfigurations."MacBook-Air" = nix-darwin.lib.darwinSystem {
      # System architecture
      system = "x86_64-darwin";

      # Pass inputs and self to modules
      specialArgs = {
        inherit inputs self;
      };

      # Configuration modules
      modules = [
        ./flake-darwin.nix    # Main Darwin system configuration
        ./flake-brew.nix      # Homebrew integration module
      ];
    };
  };
}
