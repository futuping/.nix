{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-packages.darwinModules.ego-lite
    inputs.nix-packages.darwinModules.lite-xl-app
  ];

  environment.systemPackages = with pkgs; [
    ego-lite
    lite-xl-app
  ];
}
