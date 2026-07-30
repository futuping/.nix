let
  # nix-rebuild updates these exact bindings together.
  googleChromeUrl = "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg";
  googleChromeVersion = "151.0.7922.72";
  googleChromeHash = "sha256-yDcYj9H4chDcr+weFyVypet13SHNzYqFLHr7ZLfrJUo=";
in
{
  pkgs,
  inputs,
  ...
}:
let
  thirdPartyBrewCasks = import "${inputs.brew-nix}/casks.nix" {
    inherit pkgs;
    brew-api = inputs.brew-api-extra.outPath;
  };
  # The upstream app is not Developer ID signed. Normalize its linker-generated
  # ad-hoc signature into a valid signature for the complete application bundle.
  motrixNext = thirdPartyBrewCasks."motrix-next".overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      /usr/bin/codesign --force --deep --sign - \
        "$out/Applications/MotrixNext.app"
    '';
  });
in
{
  imports = [
    inputs.brew-nix.darwinModules.default
  ];

  brew-nix.enable = true;

  environment.systemPackages = with pkgs.brewCasks; [
    # Communication
    wechat
    ayugram
    # telegram

    # AI and development
    claude
    chatgpt
    dbx

    # Web, files, and media
    motrixNext
    (google-chrome.overrideAttrs (_: {
      version = googleChromeVersion;
      src = pkgs.fetchurl {
        url = googleChromeUrl;
        hash = googleChromeHash;
      };
    }))
    # google-drive
    # c0re100-qbittorrent

    # Productivity and utilities
    launchbar
    monarch
    quakenotch
    maccy
    typora
    # keyboard-maestro
    # hammerspoon
  ];
}
