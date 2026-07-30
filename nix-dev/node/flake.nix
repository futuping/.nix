{
  description = "Reproducible Node.js environment for frontend and browser-extension development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      nodejs = pkgs.nodejs_24;

      # Pin pnpm's major version because its store and lock-file formats can
      # change between majors. flake.lock pins the exact pnpm release.
      pnpm = pkgs.pnpm_11.override {
        nodejs-slim = pkgs.nodejs-slim_24;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          nodejs
          pnpm
        ];

        # Keep TypeScript, ESLint, Vite, WXT, and framework plugins in the
        # project's package.json and pnpm-lock.yaml. Add native build tools and
        # libraries here only when a project actually needs them, for example:
        # nativeBuildInputs = [ pkgs.pkg-config pkgs.python3 ];
        # buildInputs = [ pkgs.openssl ];

        shellHook = ''
          echo "🟢 Node.js development environment activated!"
          echo "Node.js: $(node --version)"
          echo "npm: $(npm --version)"
          echo "pnpm: $(pnpm --version)"
          echo "Project tooling belongs in package.json; commit pnpm-lock.yaml."
        '';
      };

      checks.${system}.toolchain =
        pkgs.runCommand "node-toolchain-check"
          {
            nativeBuildInputs = [
              nodejs
              pnpm
            ];
          }
          ''
            {
              node --version
              npm --version
              pnpm --version
            } >"$out"
          '';

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
