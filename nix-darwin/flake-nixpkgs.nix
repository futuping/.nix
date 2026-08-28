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

    # Productivity applications
    raycast
    zotero

    # Network diagnostics
    mtr
    iperf3
  ];
}
