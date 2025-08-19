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
          path = ./rust;
          description = "A template for rust development setup.";
        };
        hello = {
          path = ./hello;
          description = "A very basic flake.";
        };
      };

      defaultTemplate = self.templates.hello;
    };
}
