{
  description = "My Personal Nix Flake Templates";

  outputs =
    { ... }:
    let
      helloTemplate = {
        path = ./nix-dev/hello;
        description = "GNU Hello package, smoke check, formatter, and Git shell for Apple Silicon macOS.";
        welcomeText = ''
          # Getting started

          - In a Git repository, stage `flake.nix` and `.gitignore` before evaluating the flake.
          - Run `nix flake lock` and commit the generated `flake.lock`.
          - Run `nix build`, `nix run`, or `nix develop`.
          - Run `nix flake check` and `nix fmt` before committing changes.
        '';
      };
    in
    {
      templates = {
        default = helloTemplate;

        nix-darwin = {
          path = ./nix-darwin;
          description = "A modular Darwin system configuration.";
        };
        rust = {
          path = ./nix-dev/rust;
          description = "A template for rust development setup.";
        };
        python = {
          path = ./nix-dev/python;
          description = "A Python 3.12 development environment with pytest tooling.";
        };
        bun = {
          path = ./nix-dev/bun;
          description = "A Bun development environment with TypeScript support.";
        };
        node = {
          path = ./nix-dev/node;
          description = "A Node.js 24 development environment with pnpm.";
        };
        hello = helloTemplate;
      };
    };
}
