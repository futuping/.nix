let
  # Set to false and rebuild to remove the Nix-managed WeType input method.
  wetypeEnable = false;
in
{
  pkgs,
  lib,
  machine,
  ...
}:

let
  # brew-nix currently handles app, pkg, and binary artifacts, but WeType is
  # published by Homebrew as an input_method artifact. Package that artifact
  # explicitly while continuing to use brew-nix for its URL, version, and hash.
  wetypeInputMethod = pkgs.brewCasks.wetype.overrideAttrs (_: {
    unpackPhase = ''
      runHook preUnpack
      unzip -q "$src"
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Library/Input Methods"
      cp -R WeType.app "$out/Library/Input Methods/"
      runHook postInstall
    '';
  });

  inputMethodsDirectory = "/Library/Input Methods";

  wetypeSource = "${wetypeInputMethod}/Library/Input Methods/WeType.app";
  # WeType 2.2.2 rejects every launch location except this exact system path.
  # Its bundled updater also hard-codes the same path.
  wetypeDirectory = inputMethodsDirectory;
  wetypeTarget = "${wetypeDirectory}/WeType.app";
  wetypeMarker = "${wetypeDirectory}/.WeType.nix-store-path";
  wetypeLegacyDirectory = "${machine.homeDirectory}/Library/Input Methods";
  wetypeLegacyTarget = "${wetypeLegacyDirectory}/WeType.app";
  wetypeLegacyMarker = "${wetypeLegacyDirectory}/.WeType.nix-store-path";
in
{
  environment.systemPackages = lib.optional wetypeEnable wetypeInputMethod;

  # Deploy the brew-nix artifact to the exact path required by WeType itself.
  # Restore writable permissions stripped by the Nix store so its updater works.
  # When disabled, remove only copies carrying this module's ownership marker.
  system.activationScripts.postActivation.text = lib.mkAfter (
    if wetypeEnable then
      ''
        (
          wetype_source=${lib.escapeShellArg wetypeSource}
          wetype_directory=${lib.escapeShellArg wetypeDirectory}
          wetype_target=${lib.escapeShellArg wetypeTarget}
          wetype_marker=${lib.escapeShellArg wetypeMarker}
          wetype_legacy_target=${lib.escapeShellArg wetypeLegacyTarget}
          wetype_legacy_marker=${lib.escapeShellArg wetypeLegacyMarker}

          # Remove only the obsolete user-scoped copy created by this module.
          if [[ -r "$wetype_legacy_marker" ]]; then
            [[ ! -e "$wetype_legacy_target" && ! -L "$wetype_legacy_target" ]] \
              || /bin/rm -rf "$wetype_legacy_target"
            /bin/rm -f "$wetype_legacy_marker"
          fi

          if [[ -d "$wetype_target" ]] \
            && [[ -r "$wetype_marker" ]] \
            && [[ "$(/bin/cat "$wetype_marker")" == "$wetype_source" ]]; then
            echo "WeType input method is already current." >&2
            exit 0
          fi

          echo "installing WeType input method..." >&2

          if [[ -e "$wetype_directory" && ! -d "$wetype_directory" ]]; then
            echo "error: WeType input method directory is not a directory: $wetype_directory" >&2
            exit 1
          fi

          if [[ ! -d "$wetype_directory" ]]; then
            /bin/mkdir -p "$wetype_directory"
            /usr/sbin/chown root:wheel "$wetype_directory"
            /bin/chmod 0755 "$wetype_directory"
          fi

          wetype_stage="$(/usr/bin/mktemp -d "$wetype_directory/.WeType.nix-darwin.XXXXXX")"
          wetype_marker_temp=""
          # shellcheck disable=SC2329 # Invoked indirectly by the EXIT trap.
          cleanup_wetype() {
            [[ -z "$wetype_stage" ]] || /bin/rm -rf "$wetype_stage"
            [[ -z "$wetype_marker_temp" ]] || /bin/rm -f "$wetype_marker_temp"
          }
          trap cleanup_wetype EXIT

          /usr/bin/ditto "$wetype_source" "$wetype_stage/WeType.app"
          /usr/sbin/chown -R root:staff "$wetype_stage/WeType.app"
          /bin/chmod -R u+rwX,g+rwX,o+rX "$wetype_stage/WeType.app"

          if [[ -e "$wetype_target" || -L "$wetype_target" ]]; then
            /bin/rm -rf "$wetype_target"
          fi
          /bin/mv "$wetype_stage/WeType.app" "$wetype_target"
          /bin/rmdir "$wetype_stage"
          wetype_stage=""

          wetype_marker_temp="$(/usr/bin/mktemp "$wetype_directory/.WeType.nix-store-path.XXXXXX")"
          printf '%s\n' "$wetype_source" >"$wetype_marker_temp"
          /usr/sbin/chown root:wheel "$wetype_marker_temp"
          /bin/chmod 0644 "$wetype_marker_temp"
          /bin/mv -f "$wetype_marker_temp" "$wetype_marker"
          wetype_marker_temp=""

          echo "installed WeType input method at $wetype_target" >&2
        )
      ''
    else
      ''
        (
          wetype_target=${lib.escapeShellArg wetypeTarget}
          wetype_marker=${lib.escapeShellArg wetypeMarker}
          wetype_legacy_target=${lib.escapeShellArg wetypeLegacyTarget}
          wetype_legacy_marker=${lib.escapeShellArg wetypeLegacyMarker}

          if [[ -r "$wetype_marker" ]]; then
            [[ ! -e "$wetype_target" && ! -L "$wetype_target" ]] \
              || /bin/rm -rf "$wetype_target"
            /bin/rm -f "$wetype_marker"
            echo "removed Nix-managed WeType input method from $wetype_target" >&2
          elif [[ -e "$wetype_target" || -L "$wetype_target" ]]; then
            echo "leaving unmanaged WeType input method at $wetype_target" >&2
          else
            echo "WeType input method is disabled." >&2
          fi

          if [[ -r "$wetype_legacy_marker" ]]; then
            [[ ! -e "$wetype_legacy_target" && ! -L "$wetype_legacy_target" ]] \
              || /bin/rm -rf "$wetype_legacy_target"
            /bin/rm -f "$wetype_legacy_marker"
          fi
        )
      ''
  );
}
