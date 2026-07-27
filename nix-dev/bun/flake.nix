{
  description = "Bun development environment with TypeScript support";

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
        bun = pkgs.bun;
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            packages = [
              bun
              typescript
            ];

            nativeBuildInputs = [
              pkg-config
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
