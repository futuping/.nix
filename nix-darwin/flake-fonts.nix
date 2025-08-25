{ pkgs, ... }:

{
  fonts.packages = [
    (pkgs.stdenv.mkDerivation {
      name = "local-fonts";
      src = ./fonts;
      installPhase = ''
        mkdir -p $out/share/fonts
        cp -R * $out/share/fonts/
      '';
    })
  ];
}
