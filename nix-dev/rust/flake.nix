{
  description = "Reproducible Rust development environment for Apple Silicon macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      rustExtensions = [
        "rust-src"
        "rust-analyzer"
        "clippy"
        "rustfmt"
      ];

      rustTargets = [
        # No extra target is installed by default. The host target,
        # aarch64-apple-darwin, is already included with the toolchain.

        # macOS on Apple Silicon (current host; normally unnecessary)
        # "aarch64-apple-darwin"

        # Windows
        # "aarch64-pc-windows-msvc" # Windows on ARM
        # "x86_64-pc-windows-msvc" # Windows on Intel/AMD

        # Linux with glibc
        # "aarch64-unknown-linux-gnu" # ARM64 Linux
        # "x86_64-unknown-linux-gnu" # Intel/AMD Linux

        # iOS and iOS Simulator (requires the matching Xcode SDK)
        # "aarch64-apple-ios" # ARM64 iPhone/iPad
        # "aarch64-apple-ios-sim" # Simulator on Apple Silicon
        # "x86_64-apple-ios" # Simulator on Intel

        # Android (requires the Android NDK)
        # "aarch64-linux-android" # ARM64
        # "armv7-linux-androideabi" # ARMv7
        # "x86_64-linux-android" # Intel/AMD 64-bit

        # WebAssembly
        # "wasm32-unknown-unknown" # Browsers and JavaScript via wasm-bindgen
        # "wasm32-wasip1" # WASI Preview 1 core modules
        # "wasm32-wasip2" # WASI Preview 2 component model
      ];

      mkRustToolchain =
        toolchain:
        toolchain.minimal.override {
          extensions = rustExtensions;
          targets = rustTargets;
        };

      # Replace `latest` with a version such as `"1.97.1"` to pin Rust
      # independently of the rust-overlay revision in flake.lock.
      stableToolchain = mkRustToolchain pkgs.rust-bin.stable.latest;

      # For a nightly-only project, a dated toolchain can instead be selected
      # with `mkRustToolchain pkgs.rust-bin.nightly."YYYY-MM-DD"`.
      nightlyToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: mkRustToolchain toolchain);

      mkRustShell =
        { toolchain }:
        pkgs.mkShell {
          packages = [
            toolchain
            pkgs.cargo-nextest
          ];

          # Add project-specific build tools and linked libraries only when
          # required, for example:
          # nativeBuildInputs = [ pkgs.pkg-config ];
          # buildInputs = [ pkgs.openssl ];

          shellHook = ''
            echo "🦀 Rust development environment activated!"
            echo "Rust: $(rustc --version)"
            echo "Cargo: $(cargo --version)"
          '';
        };
    in
    {
      devShells.${system} = {
        default = mkRustShell {
          toolchain = stableToolchain;
        };

        nightly = mkRustShell {
          toolchain = nightlyToolchain;
        };
      };

      checks.${system}.stable-toolchain =
        pkgs.runCommand "rust-stable-toolchain-check"
          {
            nativeBuildInputs = [
              stableToolchain
              pkgs.cargo-nextest
            ];
          }
          ''
            {
              rustc --version
              cargo --version
              rustfmt --version
              cargo clippy --version
              rust-analyzer --version
              cargo nextest --version
            } >"$out"
          '';

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
