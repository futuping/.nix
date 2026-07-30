{ machine, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${machine.userName} = {
      home.stateVersion = "26.05";

      programs.git = {
        enable = true;

        # Git is already installed system-wide by nix-darwin.
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
