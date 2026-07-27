let
  # nix-rebuild updates these exact bindings together.
  googleChromeUrl = "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg";
  googleChromeVersion = "150.0.7871.187";
  googleChromeHash = "sha256-NxBJKHUbVDaO8ltcDXRQpbfi9iJzH0VnHYubQnhXI0U=";
in
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.brew-nix.darwinModules.default
  ];

  brew-nix.enable = true;

  environment.systemPackages = with pkgs.brewCasks; [
    # Communication and input
    wechat
    ayugram
    # wetype
    # telegram

    # AI and development
    claude
    chatgpt
    dbx

    # Web, files, and media
    motrix
    (google-chrome.overrideAttrs (_: {
      version = googleChromeVersion;
      src = pkgs.fetchurl {
        url = googleChromeUrl;
        hash = googleChromeHash;
      };
    }))
    # google-drive
    # c0re100-qbittorrent

    # Productivity and automation
    typora
    # keyboard-maestro
    # hammerspoon
  ];
}
