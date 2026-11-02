{
  description = "Nix-managed Swift and macOS SDK development environment for Apple Silicon";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      swift = pkgs.swift;
      sdk = pkgs.apple-sdk_26;

      swiftEnvironment = {
        SWIFT_EXEC = "${swift}/bin/swiftc";
        SWIFT_EXEC_MANIFEST = "${swift}/bin/swiftc";
        SDKROOT = sdk.sdkroot;
        DEVELOPER_DIR = "${sdk}";
        MACOSX_DEPLOYMENT_TARGET = pkgs.stdenv.hostPlatform.darwinMinVersion;
      };

      # Inherited Xcode or third-party toolchain settings must not redirect
      # the compiler, package-manifest compiler, or SwiftPM support libraries.
      resetToolchainOverrides = ''
        unset SWIFT_DRIVER_SWIFT_FRONTEND_EXEC
        unset SWIFTPM_CUSTOM_BIN_DIR SWIFTPM_CUSTOM_BINDIR
        unset SWIFTPM_CUSTOM_LIBS_DIR SWIFTPM_PD_LIBS TOOLCHAINS
      '';

      tooling = [
        swift
        pkgs.swiftpm
        pkgs.sourcekit-lsp
        pkgs.swift-format
      ];

      checkEnvironment = swiftEnvironment // {
        # SwiftPM signs debug executables; pure checks need a codesign provider.
        nativeBuildInputs = tooling ++ [ pkgs.darwin.sigtool ];
        buildInputs = [ sdk ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell (
        swiftEnvironment
        // {
          packages = tooling;
          buildInputs = [ sdk ];

          # Application dependencies belong in Package.swift/Package.resolved.
          # Add native libraries and other project tools only when required.
          shellHook = ''
            ${resetToolchainOverrides}
            echo "Nix Swift development environment activated"
            swift --version
            swift package --version
            echo "macOS SDK: $SDKROOT"
            echo "Deployment target: $MACOSX_DEPLOYMENT_TARGET"
          '';
        }
      );

      checks.${system} = {
        toolchain = pkgs.runCommandCC "swift-toolchain-check" checkEnvironment ''
          ${resetToolchainOverrides}
          test "$(command -v swift)" = "${swift}/bin/swift"
          test "$(command -v swiftc)" = "$SWIFT_EXEC"
          test "$(command -v swift-build)" = "${pkgs.swiftpm}/bin/swift-build"
          test "$(command -v sourcekit-lsp)" = "${pkgs.sourcekit-lsp}/bin/sourcekit-lsp"
          test "$(command -v swift-format)" = "${pkgs.swift-format}/bin/swift-format"
          test -d "$SDKROOT/System/Library/Frameworks/SwiftUI.framework"
          swift --version
          swift package --version
          swift-format --version

          export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
          export SWIFT_MODULECACHE_PATH="$TMPDIR/swift-module-cache"
          mkdir -p source/Sources/ToolchainProbe
          cd source
          cat > Package.swift <<'EOF'
          // swift-tools-version: 6.0
          import PackageDescription

          let package = Package(
              name: "ToolchainProbe",
              platforms: [.macOS("${pkgs.stdenv.hostPlatform.darwinMinVersion}")],
              products: [.executable(name: "ToolchainProbe", targets: ["ToolchainProbe"])],
              targets: [.executableTarget(name: "ToolchainProbe")]
          )
          EOF
          cat > Sources/ToolchainProbe/main.swift <<'EOF'
          import Foundation

          struct Probe: Decodable {
              let status: String
          }

          let input = Data(#"{"status":"ready"}"#.utf8)
          let probe = try JSONDecoder().decode(Probe.self, from: input)
          precondition(probe.status == "ready")
          print("Nix SwiftPM and Foundation are ready")
          EOF
          swift build --scratch-path "$TMPDIR/swift-build" --cache-path "$TMPDIR/swift-cache"
          "$TMPDIR/swift-build/debug/ToolchainProbe" > "$out"
        '';

        apple-frameworks = pkgs.runCommandCC "swift-apple-frameworks-check" checkEnvironment ''
          ${resetToolchainOverrides}
          export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
          export SWIFT_MODULECACHE_PATH="$TMPDIR/swift-module-cache"
          cat > NativeProbe.swift <<'EOF'
          import AppKit
          import SwiftUI

          @MainActor
          public func makeProbeView() -> NSView {
              NSHostingView(rootView: Text("Native framework probe"))
          }

          @MainActor
          public func makeProbePanel() -> NSPanel {
              NSPanel(
                  contentRect: NSRect(x: 0, y: 0, width: 320, height: 160),
                  styleMask: [.borderless, .nonactivatingPanel],
                  backing: .buffered,
                  defer: true
              )
          }
          EOF
          # Compile and link the frameworks without launching a GUI session.
          swiftc -sdk "$SDKROOT" \
            -target ${pkgs.stdenv.hostPlatform.swift.triple} \
            -parse-as-library -emit-library -module-name NativeProbe \
            -framework AppKit -framework SwiftUI \
            NativeProbe.swift -o libNativeProbe.dylib
          test -s libNativeProbe.dylib
          touch "$out"
        '';
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
