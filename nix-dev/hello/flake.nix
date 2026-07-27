{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          hello = pkgs.hello;
          default = self.packages.${system}.hello;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
          ];

          shellHook = ''
            echo "🚀 Welcome to the Hello development shell!"
            echo "Git version: $(git --version)"
          '';
        };
      }
    );
}
