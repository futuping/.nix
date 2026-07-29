{
  pkgs,
  self,
  machine,
  ...
}:

let
  darwinFlakeDirectory = "${machine.configurationDirectory}/nix-darwin";
  darwinFlakeReference = "${darwinFlakeDirectory}#${machine.hostName}";
in
{
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.enable = false;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 524288000;
  };

  networking.hostName = machine.hostName;

  time.timeZone = "Pacific/Honolulu";

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  environment.systemPackages = with pkgs; [
    # Agent and development CLI tools
    git
    gh
    ripgrep
    fd
    jq
    yq-go
    nixfmt
    docker
    colima

    # Language runtimes
    nodejs_24
    (python312.withPackages (
      pythonPackages: with pythonPackages; [
        pyyaml
      ]
    ))
    go

    # AI and development applications
    ghostty-bin
    # claude-code
    # codex
    # vscode

    # Productivity applications
    raycast
    zotero

    # File synchronization
    # rclone

    # Network diagnostics
    mtr
    iperf3

    # Optional applications
    # thunder
    # FlClash
    # OpenCore-Patcher
    # Noteey
    # affine-bin
    # heptabase https://dub.sh/heptabase 7D25-C5E6-61C7-0535 https://dub.sh/hepta_doc
    # AdsPower
    # 比特浏览器
    # 闲管家-闲鱼工作台
    # 夸克网盘 # Remove the update JSON file in the app directory
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
          if ! (
            setopt local_options local_traps pipe_fail

            local chrome_config="${darwinFlakeDirectory}/flake-brew.nix"
            local chrome_releases_url="https://versionhistory.googleapis.com/v1/chrome/platforms/mac_arm64/channels/stable/versions/all/releases?filter=fraction%3D1%2Cendtime%3Dnone&order_by=version%20desc&page_size=1"
            local chrome_download_url chrome_version chrome_latest_version
            local chrome_version_comparison chrome_hash chrome_new_hash
            local chrome_temp=""

            trap '[[ -z "$chrome_temp" ]] || /bin/rm -f "$chrome_temp"' EXIT

            echo "🌐 Checking fully rolled-out Google Chrome Stable"
            if [[ ! -r "$chrome_config" || ! -w "$chrome_config" ]]; then
              echo "⚠️ Chrome configuration is not readable and writable: $chrome_config"
              exit 1
            fi

            chrome_download_url="$(
              /usr/bin/sed -n \
                's|^[[:space:]]*googleChromeUrl = "\(https://[^"]*\)";[[:space:]]*$|\1|p' \
                "$chrome_config"
            )"
            chrome_version="$(
              /usr/bin/sed -n \
                's|^[[:space:]]*googleChromeVersion = "\([^"]*\)";[[:space:]]*$|\1|p' \
                "$chrome_config"
            )"
            chrome_hash="$(
              /usr/bin/sed -n \
                's|^[[:space:]]*googleChromeHash = "\(sha256-[^"]*\)";[[:space:]]*$|\1|p' \
                "$chrome_config"
            )"

            if [[ "$chrome_download_url" != https://dl.google.com/chrome/mac/universal/stable/* ]]; then
              echo "⚠️ Chrome download URL is missing or unexpected"
              exit 1
            fi
            if [[ "$chrome_version" != <->.<->.<->.<-> ]]; then
              echo "⚠️ Configured Chrome version is missing or invalid"
              exit 1
            fi
            if [[ "$chrome_hash" != sha256-?* ]]; then
              echo "⚠️ Configured Chrome hash is missing or invalid"
              exit 1
            fi

            if ! chrome_latest_version="$(
              /usr/bin/curl --fail --silent --show-error \
                "$chrome_releases_url" |
                /usr/bin/plutil -extract releases.0.version raw -
            )"; then
              echo "⚠️ Unable to query the latest Chrome Stable version"
              exit 1
            fi
            if [[ "$chrome_latest_version" != <->.<->.<->.<-> ]]; then
              echo "⚠️ Latest Chrome Stable version is invalid: $chrome_latest_version"
              exit 1
            fi

            if ! chrome_version_comparison="$(
              nix eval --raw --expr \
                "builtins.toString (builtins.compareVersions \"$chrome_latest_version\" \"$chrome_version\")"
            )"; then
              echo "⚠️ Unable to compare Chrome versions"
              exit 1
            fi

            if [[ "$chrome_version_comparison" == 1 ]]; then
              echo "⬇️ Chrome $chrome_latest_version is newer than $chrome_version; refreshing its hash"
              if ! chrome_new_hash="$(
                nix store prefetch-file --refresh --json "$chrome_download_url" |
                  /usr/bin/plutil -extract hash raw -
              )"; then
                echo "⚠️ Unable to prefetch the latest Chrome DMG"
                exit 1
              fi
              if [[ "$chrome_new_hash" != sha256-?* ]]; then
                echo "⚠️ Prefetched Chrome hash is invalid"
                exit 1
              fi

              if [[ "$chrome_new_hash" == "$chrome_hash" ]]; then
                echo "⏳ The Stable DMG has not changed yet; deferring the Chrome update"
              else
                if ! chrome_temp="$(/usr/bin/mktemp "$chrome_config.tmp.XXXXXX")"; then
                  echo "⚠️ Unable to create a temporary Chrome configuration"
                  exit 1
                fi
                if ! /bin/cp -p "$chrome_config" "$chrome_temp"; then
                  echo "⚠️ Unable to preserve the Chrome configuration metadata"
                  exit 1
                fi
                if ! /usr/bin/awk \
                  -v version="$chrome_latest_version" \
                  -v hash="$chrome_new_hash" \
                  '
                    /^[[:space:]]*googleChromeVersion = "[^"]+";[[:space:]]*$/ {
                      version_count++
                      sub(/"[^"]+"/, "\"" version "\"")
                    }
                    /^[[:space:]]*googleChromeHash = "[^"]+";[[:space:]]*$/ {
                      hash_count++
                      sub(/"[^"]+"/, "\"" hash "\"")
                    }
                    { print }
                    END {
                      if (version_count != 1 || hash_count != 1) {
                        exit 1
                      }
                    }
                  ' \
                  "$chrome_config" > "$chrome_temp"; then
                  echo "⚠️ Unable to update the Chrome version and hash exactly once"
                  exit 1
                fi
                if ! nix-instantiate --parse "$chrome_temp" >/dev/null; then
                  echo "⚠️ Updated Chrome configuration is not valid Nix"
                  exit 1
                fi
                if ! /bin/mv -f "$chrome_temp" "$chrome_config"; then
                  echo "⚠️ Unable to replace the Chrome configuration"
                  exit 1
                fi
                chrome_temp=""
                echo "✅ Updated Chrome to $chrome_latest_version"
              fi
            elif [[ "$chrome_version_comparison" == 0 ]]; then
              echo "✅ Chrome $chrome_version is already current"
            elif [[ "$chrome_version_comparison" == -1 ]]; then
              echo "ℹ️ Configured Chrome $chrome_version is newer than published Stable; continuing"
            else
              echo "⚠️ Unexpected Chrome version comparison result: $chrome_version_comparison"
              exit 1
            fi
          ); then
            echo "⚠️ Chrome update check failed; rebuild aborted"
            return 1
          fi

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
          local template="$1"
          if [[ -z "$template" ]]; then
            template="hello"
          fi

          if [[ ! -f "flake.nix" ]]; then
            echo "🔧 Initializing new flake with template: $template"
            if ! nix flake init -t "${machine.configurationDirectory}#$template"; then
              echo "⚠️ Flake initialization interrupted or failed"
              return 1
            fi
          fi

          if [[ ! -f ".envrc" ]]; then
            echo "📝 Creating new .envrc with: use flake"
            if ! printf '%s\n' "use flake" > .envrc; then
              echo "⚠️ .envrc creation interrupted or failed"
              return 1
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
