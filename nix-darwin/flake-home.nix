{ machine, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Preserve existing files when Home Manager first takes ownership.
    backupFileExtension = "hm-backup";

    users.${machine.userName} =
      { config, lib, ... }:
      let
        sharedAgentInstructions = config.lib.file.mkOutOfStoreSymlink "${machine.configurationDirectory}/nix-darwin/dotfiles/agents/AGENTS.md";
      in
      {
        home.stateVersion = "26.05";

        # Keep one editable source for both agents; content changes need no switch.
        home.file.".codex/AGENTS.md".source = sharedAgentInstructions;
        home.file.".claude/CLAUDE.md".source = sharedAgentInstructions;

        programs.gh = {
          enable = true;

          # Preserve the existing Git authentication setup.
          gitCredentialHelper.enable = false;

          settings = {
            git_protocol = "https";
            editor = "";
            prompt = "enabled";
            prefer_editor_prompt = "disabled";
            pager = "";
            aliases.co = "pr checkout";
            http_unix_socket = "";
            browser = "";
            color_labels = "disabled";
            accessible_colors = "disabled";
            accessible_prompter = "disabled";
            spinner = "enabled";
          };
        };

        # gh already uses schema 1; leave local accounts and credentials to gh.
        home.activation.migrateGhAccounts = lib.mkForce (
          lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ""
        );

        programs.git = {
          enable = true;

          # Git is already installed system-wide through environment.systemPackages.
          package = null;

          settings = {
            user = {
              name = "Tuping Fu";
              email = "45912467+futuping@users.noreply.github.com";
              useConfigOnly = true;
            };

            init.defaultBranch = "main";
            pull.ff = "only";
            fetch.prune = true;
            push.autoSetupRemote = true;
            merge.conflictStyle = "zdiff3";
          };
        };
      };
  };
}
