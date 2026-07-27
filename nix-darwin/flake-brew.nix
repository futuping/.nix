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
    wetype
    # telegram

    # AI and development
    claude
    chatgpt
    dbx

    # Web, files, and media
    (google-chrome.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-NxBJKHUbVDaO8ltcDXRQpbfi9iJzH0VnHYubQnhXI0U=";
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
