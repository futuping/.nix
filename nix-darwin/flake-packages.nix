{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ego-lite
    shardx-launcher
    wordcraft-cli
    todesk
  ];
}
