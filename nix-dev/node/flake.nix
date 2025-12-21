{
  description = "Node.js development environment with common packages";

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
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs_22;

      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            packages = [
              nodejs
              nodePackages.pnpm
              nodePackages.typescript
            ];

            nativeBuildInputs = [
              pkg-config
            ];

            buildInputs = [
              gcc
            ];

            checkInputs = [
              nodePackages.jest
              nodePackages.mocha
            ];

            shellHook = ''
              echo "🟢 Node.js development environment activated!"
              echo "Node.js: $(node --version)"
              echo "npm: $(npm --version)"
              echo "yarn: $(yarn --version)"
              echo "pnpm: $(pnpm --version)"
              echo "TypeScript: $(tsc --version)"
            '';
          };
      }
    );
}
