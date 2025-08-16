{
  description = "My Personal Nix Flake Templates";

  outputs =
    { self, ... }:
    {
      templates = {
        nix-darwin = {
          path = ./nix;
          description = "A modular Darwin system configuration.";
        };
        rust = {
          path = ./rust;
          description = "A template for rust development setup.";
        };
        empty = {
          path = ./empty;
          description = "A very basic flake.";
        };
      };

      # Optional: Set a default template
      defaultTemplate = self.templates.empty;
    };
}
