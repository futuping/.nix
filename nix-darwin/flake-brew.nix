{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.brew-nix.darwinModules.default
    inputs.brew-nix-extra.darwinModules.google-chrome
    inputs.brew-nix-extra.darwinModules.third-party-casks
    inputs.brew-nix-extra.darwinModules.wetype
    inputs.brew-nix-extra.darwinModules.neteasemusic
  ];

  brew-nix.enable = true;

  programs.wetype.enable = true;

  environment.systemPackages = with pkgs.brewCasks; [
    # Communication
    wechat
    tencent-meeting
    ayugram
    uuremote

    # AI and development
    arcbox
    claude
    chatgpt
    dbx
    # orbstack
    zed

    # Web, files, and media
    iina
    rayburst
    neteasemusic
    # google-chrome

    # Productivity and utilities
    macshot
    # typora
  ];
}
