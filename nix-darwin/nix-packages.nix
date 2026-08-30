{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-packages.darwinModules.ego-lite
    inputs.nix-packages.darwinModules.flogravity
    inputs.nix-packages.darwinModules.neomacs
    inputs.nix-packages.darwinModules.shardx-launcher
  ];

  environment.systemPackages = with pkgs; [
    ego-lite
    flogravity
    neomacs
    shardx-launcher
  ];
}
