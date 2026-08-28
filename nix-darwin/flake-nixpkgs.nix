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

    # Language runtimes are project-scoped. Keep these declarations as
    # examples for restoring a global fallback when one is explicitly needed.
    # nodejs_24
    # (python312.withPackages (
    #   pythonPackages: with pythonPackages; [
    #     pyyaml
    #   ]
    # ))
    # go

    # Terminal
    ghostty-bin

    # Productivity applications
    raycast
    zotero

    # Network diagnostics
    mtr
    iperf3
  ];
}
