# ============================================================================
# CORE DARWIN SYSTEM CONFIGURATION
# ============================================================================
# Primary macOS system configuration module handling:
# - Essential system packages and development tools
# - Shell environment and development utilities
# - macOS system preferences and defaults
# - System services and background processes
# - User environment and productivity settings

{
  config,
  pkgs,
  lib,
  self,
  ...
}:

{
  # ============================================================================
  # NIXPKGS CONFIGURATION
  # ============================================================================
  nixpkgs.config = {
    # Allow installation of unfree packages (e.g., proprietary software)
    allowUnfree = true;
  };

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nix.settings = {
    # Enable experimental features for flakes and new nix command
    experimental-features = "nix-command flakes";
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment = {
    # System-wide packages available to all users
    systemPackages = with pkgs; [
      # Essential development tools
      nixfmt-rfc-style # Official formatter for Nix
      vim # Text editor
      git # Version control system
      nodejs # JavaScript runtime and package manager

      # Development environments and editors
      vscode # Visual Studio Code editor

      # Terminal and productivity applications
      warp-terminal # Modern terminal with AI features
      raycast # Spotlight replacement and productivity tool

      # AI and coding assistants
      claude-code # Claude AI coding assistant
    ];

    # Available shells for users
    shells = with pkgs; [ fish ];
  };

  # ============================================================================
  # PROGRAMS CONFIGURATION
  # ============================================================================
  programs = {
    # Enable Fish shell system-wide
    fish = {
      enable = true;

      # Fish shell initialization with custom functions
      interactiveShellInit = ''
        # Function to initialize a direnv flake environment, with optional template
        function nix-direnv
          # Use the first argument as template with defaults
          set template $argv[1]
          if test -z "$template"
            set template "empty"
          end

          # Check if flake.nix exists in the current directory
          if not test -f "flake.nix"
            echo "🔧 Initializing new flake with template: $template"
            if not nix flake init -t ~/.nix#$template
              echo "⚠️ Flake initialization interrupted or failed"
              return 1
            end
          end

          # Create .envrc file if it doesn't exist
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

        # Function to rebuild Darwin system
        function nix-rebuild
          echo "🔄 Updating Nix flake"
          if not nix flake update --flake ~/.nix
            echo "⚠️ Flake update interrupted or failed"
            return 1
          end

          echo "🔧 Rebuilding Darwin system"
          if not sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air
            echo "⚠️ System rebuild interrupted or failed"
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

    # Enable direnv for automatic environment loading
    direnv = {
      enable = true;
      nix-direnv.enable = true; # Better Nix integration
    };
  };

  # ============================================================================
  # SERVICES CONFIGURATION
  # ============================================================================
  services = {
    # Karabiner Elements for keyboard customization
    karabiner-elements = {
      enable = true;
      # Use specific version with custom package override
      package = pkgs.karabiner-elements.overrideAttrs (old: {
        version = "14.13.0";
        src = pkgs.fetchurl {
          inherit (old.src) url;
          hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
        };
      });
    };
  };

  # ============================================================================
  # SYSTEM CONFIGURATION
  # ============================================================================
  system = {
    # Primary user account
    primaryUser = "admin";

    # Track configuration changes
    configurationRevision = self.rev or self.dirtyRev or null;

    # Darwin state version (don't change after initial setup)
    stateVersion = 6;

    # macOS system defaults and preferences
    defaults = {
      # Dock configuration
      dock = {
        autohide = true; # Auto-hide dock when not in use
        persistent-apps = [
          "/System/Applications/Notes.app" # Keep Notes app in dock
        ];
      };

      # Finder configuration
      finder = {
        FXPreferredViewStyle = "clmv"; # Use column view by default
      };

      # Login window configuration
      loginwindow = {
        GuestEnabled = false; # Disable guest user account
      };
    };
  };
}
