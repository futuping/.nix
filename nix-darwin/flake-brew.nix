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
{
  imports = [
    inputs.brew-nix.darwinModules.default
  ];

  brew-nix.enable = true;

  programs.wetype.enable = true;

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
    motrix-next
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
