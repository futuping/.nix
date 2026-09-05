{ machine, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${machine.userName} =
      { config, ... }:
      let
        sharedAgentInstructions = config.lib.file.mkOutOfStoreSymlink "${machine.configurationDirectory}/nix-darwin/dotfiles/agents/AGENTS.md";
      in
      {
        home.stateVersion = "26.05";

        # Keep one editable source for both agents; content changes need no switch.
        home.file.".codex/AGENTS.md".source = sharedAgentInstructions;
        home.file.".claude/CLAUDE.md".source = sharedAgentInstructions;

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
