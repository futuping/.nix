{
  description = "Nix-managed Python 3.12 development environment with uv";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python312;

      nixPythonEnvironment = {
        # uv calls every non-uv installation a "system" Python. Point it at the
        # exact Nix interpreter and prevent fallback to uv-managed downloads.
        UV_PYTHON = python.interpreter;
        UV_PYTHON_DOWNLOADS = "never";
        UV_PYTHON_PREFERENCE = "only-system";
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell (
        nixPythonEnvironment
        // {
          packages = [
            python
            pkgs.uv
          ];

          # Add project-specific native tools and linked libraries only when
          # required, for example:
          # nativeBuildInputs = [ pkgs.pkg-config ];
          # buildInputs = [ pkgs.openssl ];

          shellHook = ''
            echo "🐍 Nix-managed Python development environment activated!"
            echo "Python: $(python --version)"
            echo "uv: $(uv --version)"
          '';
        }
      );

      checks.${system}.python-tooling =
        pkgs.runCommand "python-tooling-check"
          (
            nixPythonEnvironment
            // {
              nativeBuildInputs = [
                python
                pkgs.uv
              ];
            }
          )
          ''
            export UV_CACHE_DIR="$TMPDIR/uv-cache"
            {
              python --version
              uv --version
              resolved_python="$(uv python find)"
              python -c \
                'import os, sys; assert os.path.samefile(sys.argv[1], sys.argv[2])' \
                "$UV_PYTHON" "$resolved_python"
            } >"$out"
          '';

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
