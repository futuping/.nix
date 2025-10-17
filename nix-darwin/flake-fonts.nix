{
  config,
  pkgs,
  lib,
  ...
}:

let
  fonts-programming = pkgs.stdenvNoCC.mkDerivation {
    name = "fonts-programming";
    dontConfigure = true;
    src = pkgs.fetchzip {
      url = "https://github.com/futuping/fonts/releases/download/v0.2.0/fonts-programming.zip";
      sha256 = "sha256-D/hZh/ClNPQFQglGruRxitmpAfXyEhzT8Fip/YIusVY=";
      stripRoot = false;
    };

    installPhase = ''
      mkdir -p $out/share/fonts
      cp -R $src/* $out/share/fonts/
    '';
  };
in
{
  # Install font packages
  fonts.packages = with pkgs; [
    # Custom programming fonts (MonoLisa, Noto Sans Mono CJK)
    fonts-programming

    # Popular programming fonts from nixpkgs
    nerd-fonts.jetbrains-mono
  ];
}
