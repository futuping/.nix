{
  description = "Python 3.12 development environment with common packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python312;

      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            packages = [
              python
              pixi
            ];

            nativeBuildInputs = [
              pkg-config
            ];

            buildInputs = [
              gcc
            ];

            checkInputs = [
              python312Packages.pytest
              python312Packages.pytest-cov
            ];

            shellHook = ''
              echo "🐍 Python 3.12 + Pixi development environment activated!"
              echo "Python: $(python --version)"
              echo "Pixi: $(pixi --version)"
            '';
          };
      }
    );
}
