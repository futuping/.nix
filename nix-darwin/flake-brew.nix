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
    google-chrome
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
