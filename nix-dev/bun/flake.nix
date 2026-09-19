{
  description = "Reproducible Bun development environment for Apple Silicon macOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      bun = pkgs.bun;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ bun ];

        # Bun provides the runtime, package manager, test runner, and bundler.
        # Keep TypeScript, @types/bun, linters, frameworks, and other project
        # dependencies in package.json and bun.lock. Add native tools and
        # linked libraries only when a project actually needs them, for example:
        # nativeBuildInputs = [ pkgs.pkg-config pkgs.python3 ];
        # buildInputs = [ pkgs.openssl ];

        shellHook = ''
          echo "🍞 Nix-managed Bun development environment activated!"
          echo "Bun: $(bun --version)"
          echo "Revision: $(bun --revision)"
          echo "Project tooling belongs in package.json; commit bun.lock."
        '';
      };

      checks.${system}.toolchain =
        pkgs.runCommand "bun-toolchain-check"
          {
            nativeBuildInputs = [ bun ];
          }
          ''
            {
              bun --version
              bun --revision
            } >"$out"
          '';

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
