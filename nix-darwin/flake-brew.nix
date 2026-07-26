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
    # hammerspoon
    typora
    ayugram
    wechat
    # wetype
    claude
    codex-app
    dbx
    telegram

    (logseq.override { variation = "sonoma"; })
    (baidunetdisk.override { variation = "sonoma"; })
    # (antigravity.override { variation = "sonoma"; })

    (elmedia-player.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-b0khUyqKkkr02Umgi5vP4TMwZU10CLkPV/VgwbUlhJ8=";
      };
    }))
    (google-chrome.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-VdMDp0IcO4y66ih2450VM2s8yC5bSFlHvN+LvtjI4uU=";
      };
    }))
    (keyboard-maestro.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-+G0jv3KbX5otEZTmfuvHDEdWzx6U6BPW/E22385m6Z8=";
      };
    }))
    # ((antigravity.override { variation = "sonoma"; }).overrideAttrs (oldAttrs: {
    #   src = pkgs.fetchurl {
    #     url = builtins.head oldAttrs.src.urls;
    #     hash = "sha256-OTM2ohd/w3la25RQ8xHOXUU7XfDgz6I+NeQZ9G4+vCw=";
    #   };
    # }))
    # (google-drive.overrideAttrs (oldAttrs: {
    #   src = pkgs.fetchurl {
    #     url = builtins.head oldAttrs.src.urls;
    #     hash = "sha256-kIZYXE6mhdl06U97muCchTUITZ0lAsv9DbiDR29lwC8=";
    #   };
    # }))
  ];
}
