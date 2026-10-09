{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./flake-impeccable.nix
    inputs.nix-packages.darwinModules.ego-lite
    inputs.nix-packages.darwinModules.shardx-launcher
  ];

  environment.systemPackages = with pkgs; [
    ego-lite
    shardx-launcher
  ];
}
