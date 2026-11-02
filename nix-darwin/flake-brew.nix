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
    inputs.brew-nix-extra.darwinModules.uuremote
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
    android-studio

    # Web, files, and media
    search
    iina
    rayburst
    neteasemusic
    # google-chrome

    # Productivity and utilities
    macshot
    zotero
    wordcraft
    # typora
  ];
}
