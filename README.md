# .nix

Personal Nix configuration for an x86_64 macOS host, plus reusable development
flake templates.

The repository has two roles:

- `nix-darwin/` defines the macOS system.
- The root `flake.nix` exposes templates from `nix-dev/`.

This is a machine-specific configuration, not a plug-and-play distribution.
Review the assumptions and side effects below before applying it.

## Before you use it

The current Darwin configuration contains these personal defaults:

| Setting | Current value | Source |
| --- | --- | --- |
| Configuration name | `MacBook-Air` | `nix-darwin/flake.nix` |
| Platform | `x86_64-darwin` | `nix-darwin/flake.nix` |
| Primary user | `admin` | `nix-darwin/flake-darwin.nix` |
| Repository path used by Fish helpers | `~/.nix` | `nix-darwin/flake-darwin.nix` |

Change these values for the target machine. Also review the enabled packages,
services, macOS defaults, casks, App Store applications, and fonts.

Other important assumptions:

- Nix or Lix must already be installed with flakes enabled.
- `nix.enable = false`, so nix-darwin does not manage the Nix installation or
  daemon lifecycle.
- Unfree packages are allowed.
- The configuration expects the repository at `~/.nix` unless the Fish helper
  paths are changed.

### Safety notes

- `SSLKEYLOGFILE` is set to `~/.sslkeylog/sslkeylog.log`. Applications that
  support it may write TLS session keys there. Treat the file as sensitive,
  remove it after debugging, or disable the variable when it is not needed.
- The custom `nix-rebuild` Fish function updates inputs, activates the system,
  deletes old system generations, and runs garbage collection. The cleanup
  reduces rollback options; it is not equivalent to a normal rebuild.
- Custom Homebrew casks and fonts may have their own license and redistribution
  terms. Verify them before reusing or redistributing this configuration.

## Repository layout

```text
.
├── flake.nix                    # Template registry; defaults to hello
├── nix-darwin/
│   ├── flake.nix                # Host, platform, inputs, and module wiring
│   ├── flake.lock               # Locked Darwin dependencies
│   ├── flake-darwin.nix         # Packages, services, defaults, and Fish
│   ├── flake-brew.nix           # Homebrew casks and source overrides
│   ├── flake-mas.nix            # Mac App Store activation
│   └── flake-fonts.nix          # System fonts
└── nix-dev/
    ├── hello/flake.nix
    ├── rust/flake.nix
    ├── python/flake.nix
    ├── bun/flake.nix
    └── node/flake.nix
```

The Nix files are the source of truth for exact package versions and enabled
applications; the README intentionally avoids duplicating volatile inventories.

## Apply the macOS configuration

### 1. Clone to the expected path

```bash
git clone https://github.com/futuping/.nix.git ~/.nix
cd ~/.nix
```

If you use another location, replace `~/.nix` in the commands and Fish
functions.

### 2. Adapt the machine-specific settings

At minimum:

1. Rename `darwinConfigurations."MacBook-Air"` and update the rebuild command.
2. Change `system` if the Mac is not `x86_64-darwin`.
3. Change `system.primaryUser` from `admin`.
4. Review all modules under `nix-darwin/` before activation.

### 3. Bootstrap and activate

Follow the
[nix-darwin installation guide](https://github.com/nix-darwin/nix-darwin#readme)
for the first installation. Once `darwin-rebuild` is available:

```bash
sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air
```

Update inputs separately when desired:

```bash
nix flake update --flake ~/.nix/nix-darwin
sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air
```

## Use a development template

The root flake exposes these templates:

| Template | Purpose |
| --- | --- |
| `hello` | Minimal package and Git development shell; the default template |
| `rust` | Stable and nightly Rust shells with WebAssembly tooling |
| `python` | Python and Pixi development shell |
| `bun` | Bun and TypeScript development shell |
| `node` | Node.js and pnpm development shell |
| `nix-darwin` | Copy of the macOS configuration |

Initialize a project from the root template registry:

```bash
mkdir my-project
cd my-project
nix flake init --template ~/.nix#rust
nix develop
```

Use the named stable Rust shell with:

```bash
nix develop .#stable
```

For direnv:

```bash
echo "use flake" > .envrc
direnv allow
```

After the Darwin configuration has installed the custom Fish functions,
`nix-direnv [template]` combines those steps. In a directory without
`flake.nix`, it initializes `~/.nix#<template>` (default: `hello`), creates a
basic `.envrc` if needed, and allows direnv. Its argument selects a template,
not a named development shell; use `use flake .#stable` for the stable Rust
shell.

Commit the `flake.lock` generated in each initialized project when
reproducibility matters.

## Validate and maintain

Inspect the template registry and evaluate the Darwin flake before activation:

```bash
nix flake show ~/.nix
nix flake check --no-build --no-write-lock-file ~/.nix/nix-darwin
```

For a rebuild with a trace:

```bash
sudo darwin-rebuild switch \
  --flake ~/.nix/nix-darwin#MacBook-Air \
  --show-trace
```

The custom `nix-rebuild` Fish function is a convenience wrapper with four
consecutive actions:

1. `nix flake update --flake ~/.nix/nix-darwin`
2. `sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air`
3. Delete old system generations.
4. Run `nix-collect-garbage -d`.

Use the separate update and rebuild commands above when old generations must
remain available for rollback.

If a pinned Homebrew cask reports a hash mismatch, refresh only the affected
override in `nix-darwin/flake-brew.nix`. If direnv does not activate, check the
project's `.envrc`, then run `direnv allow` and `direnv status`.

## Configuration map

| Change | File |
| --- | --- |
| Host, platform, inputs, modules | `nix-darwin/flake.nix` |
| System packages, services, Fish, macOS defaults | `nix-darwin/flake-darwin.nix` |
| Homebrew casks and hashes | `nix-darwin/flake-brew.nix` |
| Mac App Store application IDs | `nix-darwin/flake-mas.nix` |
| Fonts | `nix-darwin/flake-fonts.nix` |
| Template names and paths | `flake.nix` |
| Development environments | `nix-dev/<template>/flake.nix` |
