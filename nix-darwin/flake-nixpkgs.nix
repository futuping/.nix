{ pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Agent and development CLI tools
    git
    gh
    ripgrep
    fd
    jq
    yq-go
    nixfmt

    # Language runtimes
    nodejs_24
    (python312.withPackages (
      pythonPackages: with pythonPackages; [
        pyyaml
      ]
    ))
    go

    # AI and development applications
    ghostty-bin
    lite-xl-app
    # claude-code
    # codex
    # vscode

    # Productivity applications
    raycast
    zotero

    # File synchronization
    # rclone

    # Network diagnostics
    mtr
    iperf3

    # Optional applications
    # thunder
    # FlClash
    # OpenCore-Patcher
    # Noteey
    # affine-bin
    # heptabase https://dub.sh/heptabase 7D25-C5E6-61C7-0535 https://dub.sh/hepta_doc
    # AdsPower
    # 比特浏览器
    # 闲管家-闲鱼工作台
    # 夸克网盘 # Remove the update JSON file in the app directory
  ];
}
