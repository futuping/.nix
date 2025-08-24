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

    (baidunetdisk.override { variation = "sonoma"; })

    (elmedia-player.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-DygvNHS5pp+mp0Fjh5EC0FkIbPPhu+BzYHZf3hL7ZYY=";
      };
    }))
  ];
}
