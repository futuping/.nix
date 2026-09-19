{
  description = "GNU Hello package with a Git development shell for Apple Silicon macOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      hello = pkgs.hello;
    in
    {
      packages.${system} = {
        inherit hello;
        default = hello;
      };

      checks.${system}.hello = pkgs.runCommand "hello-smoke-test" { } ''
        export LC_ALL=C
        test "$(${hello}/bin/hello)" = "Hello, world!"
        touch "$out"
      '';

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [ pkgs.git ];
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
