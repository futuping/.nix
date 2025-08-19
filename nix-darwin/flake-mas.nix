{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.mas ];

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
