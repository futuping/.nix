"""Exercise generated MAS activation with a fake sudo; never modify real apps."""

import json
import os
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parent.parent
VARIANTS = r"""
configurations:
let
  system = builtins.head (builtins.attrValues configurations);
  script = settings: (system.extendModules {
    modules = [ ({ lib, ... }: {
      programs.mas = {
        enable = lib.mkForce settings.enable;
        cleanup = lib.mkForce settings.cleanup;
        update = lib.mkForce settings.update;
        packages = lib.mkForce settings.packages;
      };
      homebrew.masApps = lib.mkForce settings.homebrewApps;
    }) ];
  }).config.system.activationScripts.mas.text;
  base = {
    enable = true;
    cleanup = true;
    update = false;
    packages = {};
    homebrewApps = {};
  };
in {
  cleanup = script base;
  managed = script (base // {
    packages = { Native = 111; Missing = 444; };
    homebrewApps.Homebrew = 222;
  });
  installOnly = script (base // {
    cleanup = false;
    update = true;
    packages = { Native = 111; Missing = 444; };
  });
  idle = script (base // { cleanup = false; });
  disabled = script (base // { enable = false; });
}
"""
scripts = json.loads(subprocess.check_output([
    "nix", "eval", "--json", "--no-update-lock-file",
    f"path:{ROOT / 'nix-darwin'}#darwinConfigurations", "--apply", VARIANTS,
], text=True))

# mas 7 prints these diagnostics even when `list` succeeds with zero apps.
WARNING = '''Warning: No installed apps found

         If this is unexpected, index apps in Spotlight (which might take some time):

         # Individual app (if the omitted apps are known). e.g., for Xcode:
         mdimport /Applications/Xcode.app

         # All apps:
         vol="$(/usr/libexec/PlistBuddy -c "Print :PreferredVolume:name" ~/Library/Preferences/com.apple.appstored.plist 2>/dev/null)"
         mdimport /Applications ${vol:+"/Volumes/${vol}/Applications"}

         # All volumes:
         sudo mdutil -Eai on
'''
APPS = """  111  Native App  (1.0)
222\tHomebrew App\t(2.0)
333  Unmanaged 应用 (Beta)  (3.0)
"""
MOCK = r"""
set -e
set -o pipefail
sudo() {
  while [[ "$1" == --* ]]; do shift; done
  shift # The absolute mas executable; never execute it.
  if [[ "$1" == list ]]; then
    cat "$TEST_STDOUT"
    cat "$TEST_STDERR" >&2
    return "$TEST_STATUS"
  fi
  printf '%s\n' "$*" >> "$TEST_CALLS"
}
"""


def check(name, variant, stdout="", stderr="", status=0, expected=()):
    with tempfile.TemporaryDirectory(prefix="mas-activation-test-") as directory:
        directory = Path(directory)
        (directory / "stdout").write_text(stdout)
        (directory / "stderr").write_text(stderr)
        calls = directory / "calls"
        calls.touch()
        environment = os.environ | {
            "TEST_STDOUT": str(directory / "stdout"),
            "TEST_STDERR": str(directory / "stderr"),
            "TEST_STATUS": str(status),
            "TEST_CALLS": str(calls),
        }
        result = subprocess.run(
            ["bash", "-c", MOCK + scripts[variant] + "\nprintf 'continued\\n'\n"],
            env=environment, text=True, capture_output=True, check=True,
        )
        actual = calls.read_text().splitlines()
        assert actual == list(expected), (name, actual, expected, result.stderr)
        assert result.stdout == "continued\n", (name, result)
        if status:
            assert "skipping App Store cleanup" in result.stderr, result.stderr
    print(f"PASS: {name}")


check("empty list", "cleanup")
check("mas 7 warnings on stderr", "cleanup", stderr=WARNING)
check("warnings on stdout", "cleanup", stdout=WARNING)
check("malformed rows", "cleanup", stdout="1234 diagnostic text\nWarning: (failure)\n")
check("valid rows mixed with warnings", "cleanup", stdout=APPS, stderr=WARNING,
      expected=("uninstall 111", "uninstall 222", "uninstall 333"))
check("failed query with partial rows", "cleanup", stdout=APPS,
      stderr="Error: query failed\n", status=1)
check("native and Homebrew keep lists", "managed", stdout=APPS, stderr=WARNING,
      expected=("install 444", "uninstall 333"))
check("install and update without cleanup", "installOnly", stdout=APPS, stderr=WARNING,
      expected=("update", "install 444"))
check("no configured work", "idle")
check("MAS disabled", "disabled")
