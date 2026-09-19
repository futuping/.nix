{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Agent and development CLI tools
    git
    gh
    ripgrep
    fd
    jq
    yq-go
    nixfmt
    nodejs_24
    (python312.withPackages (
      pythonPackages: with pythonPackages; [
        pyyaml
      ]
    ))

    # Terminal
    warp-terminal

    # Productivity applications
    zotero

    # Network diagnostics
    mtr
    iperf3
  ];
}
