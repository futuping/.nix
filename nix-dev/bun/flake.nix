{
  description = "Bun development environment with TypeScript support";

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
        bun = pkgs.bun;
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            packages = [
              bun
              nodePackages.typescript
            ];

            nativeBuildInputs = [
              pkg-config
            ];

            buildInputs = [
              gcc
            ];

            shellHook = ''
              echo "🍞 Bun development environment activated!"
              echo "Bun: $(bun --version)"
              echo "TypeScript: $(tsc --version)"
            '';
          };
      }
    );
}
