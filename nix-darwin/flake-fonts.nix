{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # System fonts from nixpkgs
      nerd-fonts.jetbrains-mono

      # Local fonts from the fonts/ directory
      (pkgs.stdenv.mkDerivation {
        name = "local-fonts";
        src = ./fonts;
        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          mkdir -p $out/share/fonts/truetype

          # Copy OTF fonts
          for otf in *.otf; do
            if [ -f "$otf" ]; then
              cp "$otf" $out/share/fonts/opentype/
            fi
          done

          # Copy TTF fonts
          for ttf in *.ttf; do
            if [ -f "$ttf" ]; then
              cp "$ttf" $out/share/fonts/truetype/
            fi
          done
        '';
      })
    ];
  };
}
