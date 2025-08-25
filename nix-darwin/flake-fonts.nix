{ pkgs, ... }:

{
  fonts.packages = [
    (pkgs.stdenv.mkDerivation {
      name = "local-fonts";
      src = ./fonts;
      installPhase = ''
        mkdir -p $out/share/fonts
        find . -name "*.otf" -o -name "*.ttf" -o -name "*.woff" -o -name "*.woff2" | while read font; do
          cp "$font" $out/share/fonts/
        done
      '';
    })
  ];
}
