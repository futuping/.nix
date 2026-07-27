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
    telegram
    ayugram
    wetype

    # AI and development
    claude
    chatgpt
    dbx

    # Web, files, and media
    google-chrome
    # google-drive
    c0re100-qbittorrent
    elmedia-player

    # Productivity and automation
    # typora
    # keyboard-maestro
    # hammerspoon
  ];
}
