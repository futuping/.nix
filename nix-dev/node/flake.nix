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
    flake-utils.lib.eachSystem [ "aarch64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs_24;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            pnpm
            pkg-config
          ];

          shellHook = ''
            echo "🟢 Node.js development environment activated!"
            echo "Node.js: $(node --version)"
            echo "npm: $(npm --version)"
            echo "pnpm: $(pnpm --version)"
            if command -v tsc >/dev/null 2>&1; then
              echo "TypeScript: $(tsc --version)"
            else
              echo "TypeScript: not installed (use pnpm add -D typescript)"
            fi
          '';
        };
      }
    );
}
