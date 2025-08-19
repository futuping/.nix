# ============================================================================
# MAC APP STORE INTEGRATION
# ============================================================================
# Module for managing Mac App Store applications using mas (Mac App Store CLI).
# Handles automatic installation of App Store applications during system activation.

{ pkgs, lib, ... }:

{
  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = [ pkgs.mas ];

  # ============================================================================
  # SYSTEM ACTIVATION SCRIPTS
  # ============================================================================
  system.activationScripts.mas.text =
    let
      applications = [
        # "808501572" # Backgrounds Dynamic Wallpapers
      ];
    in
    lib.optionalString (applications != [ ]) ''
      echo "setting up App Store applications..."
      sudo -u admin ${pkgs.mas}/bin/mas install ${lib.concatStringsSep " " applications}
    '';
}
