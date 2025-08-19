{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.brew-nix.darwinModules.default
  ];

  brew-nix.enable = true;

  environment.systemPackages = [
    (pkgs.brewCasks."c0re100-qbittorrent".overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-S9fKsdUdn7uNfphyg4GCcjKyj/SXVgvl7JSid0ZrClM=";
      };
    }))

    (pkgs.brewCasks."elmedia-player".overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-DygvNHS5pp+mp0Fjh5EC0FkIbPPhu+BzYHZf3hL7ZYY=";
      };
    }))
  ];
}
