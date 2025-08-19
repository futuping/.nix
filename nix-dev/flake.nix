{
  description = "Development Environment Templates";

  outputs =
    { self, ... }:
    {
      templates = {
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
