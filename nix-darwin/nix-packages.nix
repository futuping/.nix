{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-packages.darwinModules.ego-lite
    inputs.nix-packages.darwinModules.neomacs
    inputs.nix-packages.darwinModules.shardx-launcher
  ];

  environment.systemPackages = with pkgs; [
    ego-lite
    # Temporarily disabled because the first install builds Neomacs from source.
    # neomacs
    shardx-launcher
  ];
}
