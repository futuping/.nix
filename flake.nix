{
  description = "My Personal Nix Flake Templates";

  outputs =
    { self, ... }:
    {
      templates = {
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
          description = "A Python 3.12 development environment with Pixi package manager.";
        };
        bun = {
          path = ./nix-dev/bun;
          description = "A Bun development environment with TypeScript support.";
        };
        node = {
          path = ./nix-dev/node;
          description = "A Node.js 24 development environment with TypeScript and testing tools.";
        };
        hello = {
          path = ./nix-dev/hello;
          description = "A very basic flake.";
        };
      };

      defaultTemplate = self.templates.hello;
    };
}
