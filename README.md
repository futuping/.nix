# .nix

Personal Nix configuration for an Apple Silicon MacBook Pro, plus reusable
development flake templates.

The repository has two roles:

- `nix-darwin/` defines the macOS system.
- The root `flake.nix` exposes templates from `nix-dev/`.

This is a machine-specific configuration, not a plug-and-play distribution.
Review the assumptions and side effects below before applying it.

## Before you use it

The current Darwin configuration contains these personal defaults:

| Setting | Current value | Source |
| --- | --- | --- |
| Configuration and host name | `MacBook-Pro` | `nix-darwin/flake.nix` |
| Platform | `aarch64-darwin` | `nix-darwin/flake.nix` |
| Primary user | `level` | `nix-darwin/flake.nix` |
| Repository path used by Zsh helpers | `/Users/level/.nix` | `nix-darwin/flake.nix` |

Change these values for the target machine. Also review the enabled packages,
services, macOS defaults, casks, App Store applications, and fonts.

Other important assumptions:

- Nix or Lix must already be installed with flakes enabled.
- `nix.enable = true`, so nix-darwin manages the Nix installation, daemon, and
  `/etc/nix/nix.conf` after the first activation.
- Unfree packages are allowed.
- The configuration expects the repository at `/Users/level/.nix` unless
  `machine.configurationDirectory` is changed.

### Safety notes

- TLS key logging is disabled by default. Run `tls-debug command [arg ...]` to
  enable it for one child process. The command prints the generated key-log
  path; treat that file as sensitive and delete it after debugging.
- The custom `nix-rebuild` Zsh function first checks Google Chrome Stable and
  updates its pinned version/hash when a newer DMG is available. It then updates
  inputs, activates the system, deletes old system generations, and runs
  garbage collection. It requires network access, may modify
  `nix-darwin/flake-brew.nix` and `flake.lock`, and reduces rollback options.
- `programs.mas.cleanup = true` removes installed Mac App Store applications
  that are absent from both `programs.mas.packages` and `homebrew.masApps`.
  Keep every desired App Store application in one of those lists.
- Custom Homebrew casks and fonts may have their own license and redistribution
  terms. Verify them before reusing or redistributing this configuration.
- Third-party cask metadata is pinned separately through
  [`futuping/brew-api-extra`](https://github.com/futuping/brew-api-extra) and
  converted with the same brew-nix packaging logic as official casks.

## Repository layout

```text
.
├── flake.nix                    # Template registry; defaults to hello
├── scripts/check                # Unified repository validation
├── nix-darwin/
│   ├── flake.nix                # Host, platform, inputs, and module wiring
│   ├── flake.lock               # Locked Darwin dependencies
│   ├── flake-darwin.nix         # Packages, defaults, and Zsh
│   ├── flake-brew.nix           # Homebrew casks
│   ├── flake-mas.nix            # Native Mac App Store management
│   └── flake-fonts.nix          # System fonts
└── nix-dev/
    ├── hello/
    │   ├── flake.nix
    │   └── .gitignore
    ├── rust/flake.nix
    ├── python/flake.nix
    ├── bun/flake.nix
    └── node/flake.nix
```

The Nix files select package and runtime version lines, while `flake.lock`
records the exact Darwin input revisions. The README intentionally avoids
duplicating volatile package inventories.

## Apply the macOS configuration

### 1. Clone to the expected path

```bash
git clone https://github.com/futuping/.nix.git ~/.nix
cd ~/.nix
```

If you use another location, replace `~/.nix` in the commands and Zsh
functions.

### 2. Adapt the machine-specific settings

The `machine` attribute set in `nix-darwin/flake.nix` is the single source of
truth for machine-specific values. At minimum:

1. Change `machine.hostName`, `machine.system`, and `machine.userName`.
2. Review the derived home and configuration directories.
3. Review all modules under `nix-darwin/` before activation.

### 3. Bootstrap and activate

Follow the
[nix-darwin installation guide](https://github.com/nix-darwin/nix-darwin#readme)
for the first installation. Once `darwin-rebuild` is available:

```bash
sudo -H darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Pro
```

Update inputs separately when desired:

```bash
nix flake update --flake ~/.nix/nix-darwin
~/.nix/scripts/check
git -C ~/.nix diff -- nix-darwin/flake.lock
sudo -H darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Pro
```

## Use a development template

The root flake exposes these templates:

| Template | Purpose |
| --- | --- |
| `hello` | GNU Hello package, smoke check, formatter, and Git shell; the default template |
| `rust` | Latest stable and nightly Rust shells with WebAssembly tooling |
| `python` | Python and pytest development shell |
| `bun` | Bun and TypeScript development shell |
| `node` | Node.js and pnpm development shell |
| `nix-darwin` | Copy of the macOS configuration |

Development templates expose only `aarch64-darwin`, matching this M1 setup.

The system-level Node.js, Python, and Go installations are fallbacks for agents
and temporary scripts. A project's flake or development template owns its
runtime version; commit the project `flake.lock` and language dependency lock
files.

Initialize a project from the root template registry:

```bash
mkdir my-project
cd my-project
nix flake init --template ~/.nix#rust
nix develop
```

The default `hello` template demonstrates the standard package, check,
formatter, and development-shell workflows:

```bash
nix build
nix run
nix develop
nix flake check
nix fmt
```

When initializing inside an existing Git repository, stage the generated
`flake.nix` and `.gitignore` before running Nix commands. The template ignores
local `result` links and `.direnv/` state.

Use the named stable Rust shell with:

```bash
nix develop .#stable
```

For direnv:

```bash
echo "use flake" > .envrc
direnv allow
```

After the Darwin configuration has installed the custom Zsh functions,
`nix-direnv [template]` combines those steps. In a directory without
`flake.nix`, it initializes `~/.nix#<template>` (default: `hello`), creates a
basic `.envrc` if needed, and allows direnv. Its argument selects a template,
not a named development shell; use `use flake .#stable` for the stable Rust
shell.

Commit the `flake.lock` generated in each initialized project.

## Validate and maintain

Run the unified check before activation:

```bash
~/.nix/scripts/check
```

It checks Git whitespace, Nix formatting, the template registry, the complete
Darwin configuration, merged Zsh syntax, and every development template,
including any checks declared by a template.
Development templates currently have no lock files, so their first check needs
network access to resolve inputs; the script does not write those temporary
locks.

For a rebuild with a trace:

```bash
sudo -H darwin-rebuild switch \
  --flake ~/.nix/nix-darwin#MacBook-Pro \
  --show-trace
```

The custom `nix-rebuild` Zsh function is a convenience wrapper with five
consecutive actions:

1. Query the fully rolled-out Apple Silicon Chrome Stable release. Only a newer
   release triggers a refreshed DMG download and an atomic update of its pinned
   version and hash.
2. `nix flake update --flake ~/.nix/nix-darwin`
3. `sudo -H darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Pro`
4. Delete old system generations.
5. Run `nix-collect-garbage -d`.

If Google lists a new version before the stable DMG changes, the Chrome update
is deferred and the remaining actions continue. Review and commit any resulting
configuration and lock-file changes.

Use the separate update and rebuild commands above when old generations must
remain available for rollback.

If direnv does not activate, check the project's `.envrc`, then run
`direnv allow` and `direnv status`.

## Configuration map

| Change | File |
| --- | --- |
| Host, platform, inputs, modules | `nix-darwin/flake.nix` |
| System packages, Zsh, macOS defaults | `nix-darwin/flake-darwin.nix` |
| Homebrew casks | `nix-darwin/flake-brew.nix` |
| Mac App Store application IDs | `nix-darwin/flake-mas.nix` |
| Fonts | `nix-darwin/flake-fonts.nix` |
| Template names and paths | `flake.nix` |
| Development environments | `nix-dev/<template>/flake.nix` |
| Repository validation | `scripts/check` |
