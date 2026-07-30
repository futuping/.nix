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
          description = "Pinned stable Rust development shell with an optional nightly shell.";
          welcomeText = ''
            # Getting started

            - Run `nix flake lock` and commit `flake.lock`.
            - Run `nix develop` for stable Rust or `nix develop .#nightly` for nightly.
            - Configure components and cross-compilation targets in `flake.nix`.
            - With the custom Zsh helper, use `nix-direnv rust-nightly` for nightly.
            - For a new package, enter the shell and run `cargo init .`.
            - Keep Rust dependencies in `Cargo.toml` and commit `Cargo.lock`.
          '';
        };
        python = {
          path = ./nix-dev/python;
          description = "Nix-managed Python 3.12 and uv development environment.";
          welcomeText = ''
            # Getting started

            - In a new directory, run the custom `nix-direnv python` helper.
            - The helper initializes the template, `flake.lock`, Git baseline, and direnv.
            - For a new project, enter the shell and run `uv init --no-pin-python`.
            - Add runtime dependencies with `uv add` and development dependencies with `uv add --dev`.
            - Commit `pyproject.toml` and `uv.lock`; use `uv sync --locked` in CI.
            - Keep Python in `flake.nix`; do not use `uv python install` or `uv python pin`.
            - Add native tools and libraries to `flake.nix` only when the project needs them.
          '';
        };
        bun = {
          path = ./nix-dev/bun;
          description = "A Bun development environment with TypeScript support.";
        };
        node = {
          path = ./nix-dev/node;
          description = "A Node.js 24 and pnpm 11 environment for frontend and browser-extension development.";
          welcomeText = ''
            # Getting started

            - Run `nix flake lock` and commit `flake.lock`.
            - Run `nix develop`, or initialize with the custom `nix-direnv node` helper.
            - For a Vite frontend, run `pnpm create vite .` and follow the prompts.
            - For a WXT browser extension, run `pnpm dlx wxt@latest init . --pm pnpm`.
            - Keep TypeScript, ESLint, Vite, WXT, and framework plugins in `package.json`.
            - Commit `pnpm-lock.yaml`; use `pnpm install --frozen-lockfile` in CI.
            - Add native tools and libraries to `flake.nix` only when the project needs them.
          '';
        };
        hello = helloTemplate;
      };
    };
}
