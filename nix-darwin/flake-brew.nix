# ============================================================================
# HOMEBREW ECOSYSTEM INTEGRATION
# ============================================================================
# Dedicated module for Homebrew Cask management through brew-nix.
# Handles GUI applications and proprietary software not available in nixpkgs.
# Provides declarative management of Homebrew packages within Nix ecosystem.
#
# Key features:
# - Seamless integration between Nix and Homebrew ecosystems
# - Declarative Homebrew Cask installation and management
# - Custom package overrides and version pinning
# - Automatic dependency resolution and conflict prevention

{
  config,
  pkgs,
  inputs,
  ...
}:

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

    # qBittorrent with custom hash override
    (pkgs.brewCasks."c0re100-qbittorrent".overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        # This is the converted hash for version 5.1.2.10
        hash = "sha256-S9fKsdUdn7uNfphyg4GCcjKyj/SXVgvl7JSid0ZrClM=";
      };
    }))

    # Elmedia Player with fake hash to discover the real one
    (pkgs.brewCasks."elmedia-player".overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        # We use a fake hash to discover the real one
        hash = "sha256-DygvNHS5pp+mp0Fjh5EC0FkIbPPhu+BzYHZf3hL7ZYY=";
      };
    }))
  ];
}
