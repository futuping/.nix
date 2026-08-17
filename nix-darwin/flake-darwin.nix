{
  pkgs,
  self,
  machine,
  ...
}:

let
  darwinFlakeDirectory = "${machine.configurationDirectory}/nix-darwin";
  darwinFlakeReference = "${darwinFlakeDirectory}#${machine.hostName}";
  fontsProgramming = pkgs.stdenvNoCC.mkDerivation {
    name = "fonts-programming";
    dontConfigure = true;
    src = pkgs.fetchzip {
      url = "https://github.com/futuping/fonts/releases/download/v0.2.0/fonts-programming.zip";
      sha256 = "sha256-D/hZh/ClNPQFQglGruRxitmpAfXyEhzT8Fip/YIusVY=";
      stripRoot = false;
    };

    installPhase = ''
      mkdir -p $out/share/fonts
      cp -R $src/* $out/share/fonts/
    '';
  };
in
{
  nix.enable = false;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 524288000;
  };

  networking.hostName = machine.hostName;

  users.users.${machine.userName}.home = machine.homeDirectory;

  time.timeZone = "Pacific/Honolulu";

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  fonts.packages = with pkgs; [
    # Custom programming fonts (MonoLisa, Noto Sans Mono CJK)
    fontsProgramming

    # Popular programming fonts from nixpkgs
    nerd-fonts.jetbrains-mono
  ];

  system = {
    primaryUser = machine.userName;
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
    defaults = {
      dock = {
        autohide = true;
        persistent-apps = [
          "/System/Applications/Notes.app"
        ];
      };

      finder = {
        FXPreferredViewStyle = "clmv";
      };

      loginwindow = {
        GuestEnabled = false;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = false;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleLanguages = [ "en-GB" ];
          AppleLocale = "en_GB@rg=USzzzz";
        };

        "com.apple.commerce".AutoUpdate = false;
      };
    };
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zsh = {
      enable = true;
      interactiveShellInit = ''
        tls-debug() (
          if (( $# == 0 )); then
            print -u2 'usage: tls-debug command [arg ...]'
            return 64
          fi

          local keylog_dir keylog_file
          if [[ -n "$XDG_STATE_HOME" ]]; then
            keylog_dir="$XDG_STATE_HOME/tls-keylogs"
          else
            keylog_dir="$HOME/.local/state/tls-keylogs"
          fi

          umask 077
          command mkdir -p "$keylog_dir" || return 1
          command chmod 700 "$keylog_dir" || return 1
          keylog_file="$(command mktemp "$keylog_dir/sslkeylog.XXXXXX")" || return 1
          command chmod 600 "$keylog_file" || return 1

          print -r -- "TLS key log: $keylog_file"
          print -r -- 'Delete this file after debugging.'
          SSLKEYLOGFILE="$keylog_file" "$@"
        )

        nix-rebuild() {
          echo "🔄 Updating Nix flake"
          if ! nix flake update --flake "${darwinFlakeDirectory}"; then
            echo "⚠️ Flake update interrupted or failed"
            return 1
          fi

          echo "🔧 Rebuilding Darwin system"
          if ! sudo -H darwin-rebuild switch --flake "${darwinFlakeReference}"; then
            echo "⚠️ System rebuild interrupted or failed"
            return 1
          fi

          echo "🧹 Deleting old system generations"
          if ! sudo -H nix-env --delete-generations old --profile /nix/var/nix/profiles/system; then
            echo "⚠️ Old generation deletion interrupted or failed"
            return 1
          fi

          echo "🗑️ Collecting garbage"
          if ! nix-collect-garbage -d; then
            echo "⚠️ Garbage collection interrupted or failed"
            return 1
          fi

          echo "✅ Nix system rebuild complete"
        }

        nix-direnv() {
          local requested="$1"
          if [[ -z "$requested" ]]; then
            requested="hello"
          fi

          local template="$requested"
          local envrc_line="use flake"

          local initialized_flake=0
          local initialized_envrc=0
          local initialized_repository=0
          local gitignore_was_present=0
          [[ -f ".gitignore" ]] && gitignore_was_present=1

          if [[ ! -f "flake.nix" ]]; then
            echo "🔧 Initializing new flake with template: $template"
            if ! nix flake init -t "${machine.configurationDirectory}#$template"; then
              echo "⚠️ Flake initialization interrupted or failed"
              return 1
            fi
            initialized_flake=1
          fi

          if [[ ! -f ".envrc" ]]; then
            echo "📝 Creating new .envrc with: $envrc_line"
            if ! printf '%s\n' "$envrc_line" > .envrc; then
              echo "⚠️ .envrc creation interrupted or failed"
              return 1
            fi
            initialized_envrc=1
          fi

          if (( initialized_flake )); then
            if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              echo "🌱 Initializing Git repository"
              if ! git init; then
                echo "⚠️ Git initialization interrupted or failed"
                return 1
              fi
              initialized_repository=1
            fi

            local -a environment_files
            environment_files=(flake.nix)
            if (( ! gitignore_was_present )) && [[ -f ".gitignore" ]]; then
              environment_files+=(.gitignore)
            fi
            if (( initialized_envrc )) && ! git check-ignore -q -- .envrc 2>/dev/null; then
              environment_files+=(.envrc)
            fi

            echo "📌 Staging generated environment files"
            if ! git add -- "''${environment_files[@]}"; then
              echo "⚠️ Unable to stage generated environment files"
              return 1
            fi

            echo "🔒 Locking flake inputs"
            if ! nix flake lock; then
              echo "⚠️ Flake input locking interrupted or failed"
              return 1
            fi
            if ! git add -- flake.lock; then
              echo "⚠️ Unable to stage flake.lock"
              return 1
            fi

            if (( initialized_repository )); then
              if [[ -n "$(git config user.name)" && -n "$(git config user.email)" ]]; then
                echo "🧾 Creating initial Git commit"
                if ! git commit -m "Initialize $template development environment"; then
                  echo "⚠️ Initial Git commit failed; generated files remain staged"
                fi
              else
                echo "⚠️ Git identity is not configured; initial commit skipped"
                echo "   Generated environment files remain staged."
              fi
            fi
          fi

          echo "📁 Setting up direnv environment"
          if ! direnv allow; then
            echo "⚠️ Direnv setup interrupted or failed"
            return 1
          fi

          echo "🔄 Loading direnv environment"
        }
      '';
    };
  };
}
