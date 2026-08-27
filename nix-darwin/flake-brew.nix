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
in
{
  imports = [
    inputs.brew-nix.darwinModules.default
  ];

  brew-nix.enable = true;

  programs = {
    # awesun.enable = false;
    wetype.enable = true;
  };

  environment.systemPackages = with pkgs.brewCasks; [
    # Communication
    wechat
    tencent-meeting
    ayugram
    uuremote
    # telegram

    # AI and development
    claude
    chatgpt
    dbx
    orbstack

    # Web, files, and media
    motrix-next
    neteasemusic
    google-chrome
    # google-drive
    # c0re100-qbittorrent

    # Productivity and utilities
    launchbar
    monarch
    quakenotch
    maccy
    typora
    thirdPartyBrewCasks.tinycast
    # keyboard-maestro
    # hammerspoon
  ];
}
