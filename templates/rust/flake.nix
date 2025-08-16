{
  description = "Rust development environment with stable and nightly shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        # Common components for both Rust toolchains to avoid repetition.
        commonRustComponents = {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
            "rustfmt"
          ];
          targets = [
            "wasm32-unknown-unknown"
          ];
        };

        # Define the specific toolchains.
        stableToolchain = pkgs.rust-bin.stable."1.88.0".default.override commonRustComponents;
        nightlyToolchain = pkgs.rust-bin.nightly."2025-05-09".default.override commonRustComponents;

        # Helper function to create a consistent shell environment.
        # This now uses `with pkgs;` for conciseness.
        mkRustShell =
          { toolchain, name }:
          with pkgs;
          mkShell {
            packages = [
              toolchain
              cargo-nextest
            ];

            nativeBuildInputs = [
              pkg-config
            ];

            buildInputs = [
              openssl.dev
            ];

            shellHook = ''
              echo "🦀 ${name} Rust development environment activated!"
              echo "Rust: $(rustc --version)"
              echo "Cargo: $(cargo --version)"
            '';
          };

      in
      {
        devShells = {
          default = mkRustShell {
            toolchain = nightlyToolchain;
            name = "Nightly";
          };
          stable = mkRustShell {
            toolchain = stableToolchain;
            name = "Stable";
          };
        };
      }
    );
}
