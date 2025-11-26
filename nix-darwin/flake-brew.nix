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
    c0re100-qbittorrent
    hammerspoon
    typora
    ayugram
    wechat
    # thunder

    (logseq.override { variation = "sonoma"; })
    (baidunetdisk.override { variation = "sonoma"; })
    (antigravity.override { variation = "sonoma"; })

    (elmedia-player.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-pVx9wowtYvxRVaQAd49b9tgjtcSK9M1ngZ8/2IFdi1I=";
      };
    }))
    (google-chrome.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-3tGFRcWoAu8EUMRpKWBfKRBsBuJtVl2mZurujkmiUcA=";
      };
    }))
    # ((antigravity.override { variation = "sonoma"; }).overrideAttrs (oldAttrs: {
    #   src = pkgs.fetchurl {
    #     url = builtins.head oldAttrs.src.urls;
    #     hash = "sha256-OTM2ohd/w3la25RQ8xHOXUU7XfDgz6I+NeQZ9G4+vCw=";
    #   };
    # }))
    (keyboard-maestro.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-+G0jv3KbX5otEZTmfuvHDEdWzx6U6BPW/E22385m6Z8=";
      };
    }))
    # (google-drive.overrideAttrs (oldAttrs: {
    #   src = pkgs.fetchurl {
    #     url = builtins.head oldAttrs.src.urls;
    #     hash = "sha256-kIZYXE6mhdl06U97muCchTUITZ0lAsv9DbiDR29lwC8=";
    #   };
    # }))
  ];
}
