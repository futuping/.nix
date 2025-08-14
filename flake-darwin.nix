# ============================================================================
# DARWIN SYSTEM CONFIGURATION
# ============================================================================
# This file contains the main Darwin system configuration for macOS.
# It handles system settings, services, packages, and user environment.

{ config, pkgs, lib, self, ... }:

{
  # ============================================================================
  # NIXPKGS CONFIGURATION
  # ============================================================================
  nixpkgs.config = {
    # Allow installation of unfree packages (e.g., proprietary software)
    allowUnfree = true;
  };

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nix.settings = {
    # Enable experimental features for flakes and new nix command
    experimental-features = "nix-command flakes";
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Essential development tools
    vim                 # Text editor
    git                 # Version control system
  ];

  # ============================================================================
  # PROGRAMS CONFIGURATION
  # ============================================================================
  programs = {
    # Enable Zsh shell system-wide
    zsh.enable = true;

    # Enable direnv for automatic environment loading
    direnv = {
      enable = true;
      nix-direnv.enable = true;  # Better Nix integration
    };
  };

  # ============================================================================
  # SERVICES CONFIGURATION
  # ============================================================================
  services = {
    # Karabiner Elements for keyboard customization
    karabiner-elements = {
      enable = true;
      # Use specific version with custom package override
      package = pkgs.karabiner-elements.overrideAttrs (old: {
        version = "14.13.0";
        src = pkgs.fetchurl {
          inherit (old.src) url;
          hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
        };
      });
    };
  };

  # ============================================================================
  # SYSTEM CONFIGURATION
  # ============================================================================
  system = {
    # Primary user account
    primaryUser = "admin";

    # Track configuration changes
    configurationRevision = self.rev or self.dirtyRev or null;

    # Darwin state version (don't change after initial setup)
    stateVersion = 6;

    # macOS system defaults and preferences
    defaults = {
      # Dock configuration
      dock = {
        autohide = true;  # Auto-hide dock when not in use
        persistent-apps = [
          "/System/Applications/Notes.app"  # Keep Notes app in dock
        ];
      };

      # Finder configuration
      finder = {
        FXPreferredViewStyle = "clmv";  # Use column view by default
      };

      # Login window configuration
      loginwindow = {
        GuestEnabled = false;  # Disable guest user account
      };
    };
  };
}
