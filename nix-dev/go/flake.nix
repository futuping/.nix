{
  description = "Nix-managed Go development environment for Apple Silicon macOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      go = pkgs.go;

      goEnvironment = {
        # Use the Nix-pinned compiler instead of downloading another toolchain
        # when go.mod or go.work requests a newer Go release.
        GOTOOLCHAIN = "local";
      };

      tooling = [
        go
        pkgs.gopls
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell (
        goEnvironment
        // {
          packages = tooling;

          # Keep Go dependencies in go.mod and go.sum. Add project-specific
          # native tools and linked libraries only when required, for example:
          # nativeBuildInputs = [ pkgs.pkg-config ];
          # buildInputs = [ pkgs.openssl ];

          shellHook = ''
            echo "Go development environment activated!"
            go version
            gopls version
          '';
        }
      );

      checks.${system}.toolchain =
        pkgs.runCommand "go-toolchain-check"
          (
            goEnvironment
            // {
              nativeBuildInputs = tooling;
            }
          )
          ''
            export GOCACHE="$TMPDIR/go-cache"
            export GOPATH="$TMPDIR/go"
            export GOPROXY=off
            go version
            gopls version
            # Go ignores go.mod directly in the system temporary directory.
            mkdir source
            cd source
            go mod init example.com/toolchain-check
            cat > main.go <<'EOF'
            package main

            import "fmt"

            func main() { fmt.Println("Hello, Go!") }
            EOF
            go build -o hello .
            test "$(./hello)" = "Hello, Go!"
            touch "$out"
          '';

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
