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
  };

  # ============================================================================
  # OUTPUTS
  # ============================================================================
  outputs = inputs@{ self, nixpkgs, nix-darwin, ... }: {
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
        ./flake-darwin.nix
      ];
    };
  };
}
