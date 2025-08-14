# ============================================================================
# HOMEBREW INTEGRATION MODULE
# ============================================================================
# This module handles the brew-nix integration and all Homebrew Cask installations.
# It provides a bridge between Nix and Homebrew for packages not available in nixpkgs.

{ config, pkgs, inputs, ... }:

{
  # ============================================================================
  # MODULE IMPORTS
  # ============================================================================
  # Import brew-nix module for Homebrew integration
  imports = [
    inputs.brew-nix.darwinModules.default
  ];

  # ============================================================================
  # BREW-NIX CONFIGURATION
  # ============================================================================
  # Enable the brew-nix module system for Homebrew package management
  brew-nix.enable = true;

  # ============================================================================
  # HOMEBREW CASK PACKAGES
  # ============================================================================
  # Add Homebrew Casks to system packages here
  # These are typically GUI applications not available in nixpkgs
  environment.systemPackages = [
    # Example: Custom package override with specific variation and hash
    #(
    #  (pkgs.brewCasks.mihomo-party.override { variation = "sonoma"; })
    #  .overrideAttrs (oldAttrs: {
    #    src = pkgs.fetchurl {
    #      url = builtins.head oldAttrs.src.urls;
    #      hash = "sha256-mS/EXKHSljCQ/PVFuI75SK3h8WEwrxUFuKSQhhkJVvI=";
    #    };
    #  })
    #)
    
    # Add your Homebrew Cask packages here
    # Example: pkgs.brewCasks.package-name
  ];
}
