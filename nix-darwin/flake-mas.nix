{ inputs, lib, ... }:

let
  # The pinned upstream module merges mas diagnostics into its app list.
  # Patch only the parser and failed-query handling, retaining its options.
  upstream = builtins.readFile "${inputs.nix-darwin}/modules/programs/mas.nix";
  replacements = [
    {
      before = "id=\"''\${line%% *}\"";
      after = ''
        appLinePattern='^([0-9]+)[[:space:]]+.+[[:space:]]+\([^()]+\)[[:space:]]*$'
        [[ "$line" =~ $appLinePattern ]] || continue
        id="${"''"}''${BASH_REMATCH[1]}"
      '';
      occurrences = 2;
    }
    {
      before = "for installedId in \"''\${installedIds[@]}\"; do";
      after = ''
        if (( listStatus != 0 )); then
          echo >&2 "warning: skipping App Store cleanup because mas list failed"
          installedIds=()
        fi

        for installedId in "${"''"}''${installedIds[@]}"; do
      '';
      occurrences = 1;
    }
  ];
  patched = lib.foldl' (
    source: replacement:
    # Fail explicitly when an input update changes the code being patched.
    assert lib.assertMsg (
      builtins.length (lib.splitString replacement.before source) == replacement.occurrences + 1
    ) "The upstream mas module changed; review flake-mas.nix.";
    lib.replaceStrings [ replacement.before ] [ replacement.after ] source
  ) upstream replacements;
in
{
  disabledModules = [ "programs/mas.nix" ];
  imports = [ (builtins.toFile "mas-list-fix-upstream.nix" patched) ];

  programs.mas = {
    enable = true;
    cleanup = true;
    update = false;

    packages = {
      # Infuse = 1136220934;
    };
  };
}
