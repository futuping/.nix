{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-packages.darwinModules.ego-lite
    inputs.nix-packages.darwinModules.lite-xl-app
    inputs.nix-packages.darwinModules.shardx-launcher
  ];

  environment.systemPackages =
    (with pkgs; [
      ego-lite
      lite-xl-app
      shardx-launcher
    ])
    ++ [
      inputs.nix-packages.packages.${pkgs.stdenv.hostPlatform.system}.neomacs
    ];
}
