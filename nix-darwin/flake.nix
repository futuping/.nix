# ============================================================================
# DARWIN SYSTEM FLAKE
# ============================================================================
# Main flake configuration for macOS Darwin system management.
# Integrates nix-darwin, Homebrew, and npm package ecosystems.

{
  description = "Modular Darwin system configuration with multi-ecosystem package management";

  # ============================================================================
  # FLAKE INPUTS
  # ============================================================================
  inputs = {
    # Core Nix ecosystem
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      # Using unstable channel for latest packages and security updates
    };

    # Darwin system management
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
      # Ensures consistent nixpkgs version across all inputs
    };

    # Homebrew ecosystem integration
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.brew-api.follows = "brew-api";
      # Provides Homebrew Cask integration for GUI applications
    };

    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
      # Non-flake input containing Homebrew package definitions
    };

    # Node.js ecosystem integration
    npmpackages = {
      url = "github:futuping/npmpackages";
      flake = false;
      # Non-flake input for npm package management through Nix
    };
  };

  # ============================================================================
  # SYSTEM OUTPUTS
  # ============================================================================
  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      brew-nix,
      brew-api,
      npmpackages,
      ...
    }:
    {
      # Darwin system configurations
      darwinConfigurations = {
        # Primary system configuration for MacBook-Air
        "MacBook-Air" = nix-darwin.lib.darwinSystem {
          # Target system architecture
          system = "x86_64-darwin";

          # Special arguments passed to all modules
          specialArgs = {
            inherit inputs self;
            # Provides access to flake inputs and self-reference in modules
          };

          # Modular configuration structure
          modules = [
            ./flake-darwin.nix # Core Darwin system configuration
            ./flake-brew.nix # Homebrew Cask integration
            ./flake-npm.nix # Node.js/npm package management
          ];
        };
      };
    };
}
