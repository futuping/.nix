{
  config,
  pkgs,
  lib,
  self,
  ...
}:

{
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.enable = false;
  # nix.settings = {
  #   experimental-features = [
  #     "nix-command"
  #     "flakes"
  #   ];
  # };

  environment = {
    systemPackages = with pkgs; [
      nixfmt-rfc-style
      git
      vscode
      warp-terminal
      raycast
      claude-code
      emacs
      codex
      zotero
      affine-bin
      rclone
      mtr
      iperf3
      # OpenCore-Patcher
      # sparkle
      # comet
      # kuake-drive # Remove the update JSON file in the app directory
      # google-drive
      # heptabase https://dub.sh/heptabase 7D25-C5E6-61C7-0535 https://dub.sh/hepta_doc
      # Noteey
      # wireshark # Install ChmodBPF from the official DMG
    ];

    shells = with pkgs; [ fish ];

    variables = {
      SSLKEYLOGFILE = "$HOME/.sslkeylog/sslkeylog.log";
    };
  };

  services = {
    karabiner-elements = {
      enable = true;
      package = pkgs.karabiner-elements.overrideAttrs (old: {
        version = "14.13.0";
        src = pkgs.fetchurl {
          inherit (old.src) url;
          hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
        };
      });
    };

    emacs = {
      enable = true;
      package = pkgs.emacs;
      #   package = pkgs.emacs.overrideAttrs (old: {
      #     buildInputs = old.buildInputs ++ [ pkgs.imagemagick ];
      #     configureFlags = old.configureFlags ++ [
      #       "--with-modules"
      #       "--with-dbus"
      #       "--with-xwidgets"
      #       "--with-imagemagick"
      #     ];
      #   });
    };
  };

  system = {
    primaryUser = "admin";
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

    fish = {
      enable = true;
      interactiveShellInit = ''
        function nix-direnv
          set template $argv[1]
          if test -z "$template"
            set template "hello"
          end

          if not test -f "flake.nix"
            echo "🔧 Initializing new flake with template: $template"
            if not nix flake init -t ~/.nix#$template
              echo "⚠️ Flake initialization interrupted or failed"
              return 1
            end
          end

          if not test -f ".envrc"
            echo "📝 Creating new .envrc with: use flake"
            if not echo "use flake" > .envrc
              echo "⚠️ .envrc creation interrupted or failed"
              return 1
            end
          end

          echo "📁 Setting up direnv environment"
          if not direnv allow
            echo "⚠️ Direnv setup interrupted or failed"
            return 1
          end

          echo "🔄 Loading direnv environment"
        end

        function nix-rebuild
          echo "🔄 Updating Nix flake"
          if not nix flake update --flake ~/.nix/nix-darwin
            echo "⚠️ Flake update interrupted or failed"
            return 1
          end

          echo "🔧 Rebuilding Darwin system"
          if not sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air
            echo "⚠️ System rebuild interrupted or failed"
            return 1
          end

          echo "🧹 Deleting old system generations"
          if not sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
            echo "⚠️ Old generation deletion interrupted or failed"
            return 1
          end

          echo "🗑️ Collecting garbage"
          if not nix-collect-garbage -d
            echo "⚠️ Garbage collection interrupted or failed"
            return 1
          end

          echo "✅ Nix system rebuild complete"
        end

      '';
    };
  };
}
