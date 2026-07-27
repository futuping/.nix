{
  description = "Python 3.12 development environment with common packages";

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
        python = pkgs.python312;

      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            packages = [
              python
              python312Packages.pytest
              python312Packages.pytest-cov
            ];

            nativeBuildInputs = [
              pkg-config
            ];

            shellHook = ''
              echo "🐍 Python 3.12 development environment activated!"
              echo "Python: $(python --version)"
              echo "pytest: $(pytest --version)"
            '';
          };
      }
    );
}
