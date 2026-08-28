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

  programs = {
    wetype.enable = true;
  };

  environment.systemPackages = with pkgs.brewCasks; [
    # Communication
    wechat
    tencent-meeting
    ayugram
    uuremote

    # AI and development
    claude
    chatgpt
    dbx
    orbstack

    # Web, files, and media
    motrix-next
    neteasemusic
    google-chrome

    # Productivity and utilities
    typora
    tinycast
  ];
}
