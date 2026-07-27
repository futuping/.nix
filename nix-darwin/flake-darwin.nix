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

  nix.enable = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 524288000;
  };

  networking.hostName = machine.hostName;

  environment.systemPackages = with pkgs; [
    # Agent and development CLI tools
    git
    gh
    ripgrep
    fd
    jq
    yq-go
    nixfmt

    # Language runtimes
    nodejs_24
    python312
    go

    # AI and development applications
    cmux
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
    # affine-bin
    # warp-terminal
    # OpenCore-Patcher
    # comet
    # kuake-drive # Remove the update JSON file in the app directory
    # heptabase https://dub.sh/heptabase 7D25-C5E6-61C7-0535 https://dub.sh/hepta_doc
    # Noteey
    # wireshark # Install ChmodBPF from the official DMG
    # thunder
    # 比特浏览器
    # 闲管家-闲鱼工作台
    # FLClash
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
        _HIHideMenuBar = true;
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

        chrome-hash() {
          setopt local_options pipe_fail
          local hash
          hash="$(
            nix store prefetch-file --json \
              "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg" |
              /usr/bin/plutil -extract hash raw -
          )" || return 1
          print -r -- "hash = \"$hash\";"
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

        nix-rebuild() {
          echo "🔄 Updating Nix flake"
          if ! nix flake update --flake "${darwinFlakeDirectory}"; then
            echo "⚠️ Flake update interrupted or failed"
            return 1
          fi

          echo "🔧 Rebuilding Darwin system"
          if ! sudo darwin-rebuild switch --flake "${darwinFlakeReference}"; then
            echo "⚠️ System rebuild interrupted or failed"
            return 1
          fi

          echo "🧹 Deleting old system generations"
          if ! sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system; then
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
      '';
    };
  };
}
