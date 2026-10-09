{ pkgs, machine, ... }:
let
  engine = pkgs.callPackage ./packages/impeccable-engine.nix { };
in
{
  environment.systemPackages = [ engine ];
  home-manager.users.${machine.userName} = { lib, ... }: {
    # Keep the installed skill's version-pinned launcher cache backed by Nix.
    home.file.".impeccable/bin/${engine.version}/impeccable".source = "${engine}/bin/impeccable-engine";
    home.activation.repairImpeccableLauncher = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      launcher="$HOME/.codex/skills/impeccable/scripts/impeccable"
      if [ -f "$launcher" ] && [ ! -x "$launcher" ]; then
        chmod u+x "$launcher"
      fi
    '';
  };
}
