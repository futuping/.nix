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
| Git commit identity | `Tuping Fu <45912467+futuping@users.noreply.github.com>` | `nix-darwin/flake-home.nix` |
| Home Manager state version | `26.05` | `nix-darwin/flake-home.nix` |

Change these values for the target machine. Also review the enabled packages,
services, macOS defaults, casks, App Store applications, and fonts.

Other important assumptions:

- Nix or Lix must already be installed with flakes enabled.
- `nix.enable = true`, so nix-darwin manages the Nix installation, daemon, and
  `/etc/nix/nix.conf` after the first activation.
- Unfree packages are allowed.
- The configuration expects the repository at `/Users/level/.nix` unless
  `machine.configurationDirectory` is changed.
- Home Manager is integrated as a nix-darwin module and owns the primary
  user's global Git configuration.

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
│   ├── flake-home.nix           # Home Manager and per-user Git configuration
│   ├── flake-brew.nix           # Homebrew casks
│   ├── flake-mas.nix            # Native Mac App Store management
│   ├── flake-fonts.nix          # System fonts
│   └── packages/
│       └── lite-xl-app.nix      # Official Lite XL macOS application
└── nix-dev/
    ├── hello/
    │   ├── flake.nix
    │   └── .gitignore
    ├── rust/
    │   ├── flake.nix
    │   └── .gitignore
    ├── python/flake.nix
    ├── bun/
    │   ├── flake.nix
    │   └── .gitignore
    └── node/
        ├── flake.nix
        └── .gitignore
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
| `rust` | Stable-by-default Rust shell, optional nightly, and target examples |
| `python` | Nix-managed Python 3.12 and uv development shell |
| `bun` | Nix-managed Bun shell for JavaScript and TypeScript projects |
| `node` | Node.js 24 and pnpm 11 shell for frontend and browser-extension development |
| `nix-darwin` | Copy of the macOS configuration |

Development templates expose only `aarch64-darwin`, matching this M1 setup.

The system-level Node.js, Python, and Go installations are fallbacks for agents
and temporary scripts. Rust is intentionally project-scoped instead of being a
Darwin system package. A project's flake or development template owns its
runtime version; commit the project `flake.lock` and language dependency lock
files.

Initialize a project from the root template registry:

```bash
mkdir my-project
cd my-project
nix flake init --template ~/.nix#rust
nix flake lock
nix develop
```

For a new Rust package, run `cargo init .` after entering the development
shell. The project `flake.nix` owns the Rust channel, components, and optional
cross-compilation targets; `flake.lock` pins the Nixpkgs and rust-overlay
revisions. `Cargo.toml` and `Cargo.lock` remain the source of truth for Rust
crate dependencies.

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

Use the optional nightly Rust shell with:

```bash
nix develop .#nightly
```

The nightly shell uses rust-overlay's latest nightly that contains the
configured components and targets; the committed `flake.lock` pins the selected
rust-overlay snapshot. The template uses the minimal profile and adds the
development components explicitly, so it does not install the offline
`rust-docs` component. Comments beside `rustTargets` show common macOS,
Windows, Linux, iOS, Android, browser WebAssembly, and WASI target triples.
Uncomment only those required by the project.

The generic template deliberately does not inject native libraries. When a
crate actually needs them, add build tools such as `pkgs.pkg-config` to
`nativeBuildInputs` and linked libraries such as `pkgs.openssl` to
`buildInputs` in that project's shell.

The Python template follows the same boundary as the Rust template: the
project flake owns the interpreter and native dependencies, while the language
package manager owns project dependencies. Initialize a new environment with
the custom helper:

```bash
mkdir my-python-project
cd my-python-project
nix-direnv python
```

When creating a template, the helper also creates `.envrc` and `flake.lock`,
stages the generated environment files, and allows direnv. In a new directory
it initializes Git and creates the initial commit when a Git name and email are
configured; otherwise it leaves the files staged and continues. It never
automatically commits in an existing repository.

For a new uv project, initialize it without a `.python-version` file because
the interpreter is already selected and pinned by Nix:

```bash
uv init --no-pin-python
uv add --dev pytest pytest-cov
uv sync
uv run pytest
```

The shell sets `UV_PYTHON` to the exact Nix store interpreter, restricts uv to
non-uv-managed Python installations, and disables Python downloads. Do not use
`uv python install` or `uv python pin` in these projects. Declare supported
Python versions with `requires-python` in `pyproject.toml`, and commit both
`flake.lock` and `uv.lock`.

Use `uv sync --locked` and `uv run --locked ...` in CI so an outdated or
missing lock file fails instead of being changed. Development dependencies
belong in the standard `dependency-groups.dev` group and are synced by default.
These behaviors follow uv's official documentation for
[Python discovery and managed versions](https://docs.astral.sh/uv/concepts/python-versions/),
[project initialization](https://docs.astral.sh/uv/reference/cli/#uv-init), and
[locking and syncing](https://docs.astral.sh/uv/concepts/projects/sync/).

Like the Rust template, the generic Python shell deliberately omits native
libraries. Add build tools such as `pkgs.pkg-config` to `nativeBuildInputs` and
linked libraries such as `pkgs.openssl` to `buildInputs` only when a project
requires them. Add Python runtime and development packages with `uv add`, not
`python.withPackages`.

The Bun template keeps a similar boundary: Nix provides Bun and pins its exact
release through `flake.lock`; Bun owns the JavaScript dependency graph through
`package.json` and `bun.lock`. Initialize the environment and project with:

```bash
mkdir my-bun-project
cd my-bun-project
nix-direnv bun
bun init
```

`bun init` creates the project files, configures TypeScript editor support, and
installs `@types/bun`. Bun can directly execute TypeScript, but its transpiler
and bundler do not replace `tsc` for type checking or declaration generation.
When a project needs an explicit type-checking step, add TypeScript locally and
run it through a package script:

```bash
bun add --dev typescript
bun pm pkg set scripts.typecheck="tsc --noEmit"
bun run typecheck
```

Keep TypeScript, linters, formatters, frameworks, and application dependencies
in `package.json`; do not add them to the Nix shell. Commit both `flake.lock`
and the text-based `bun.lock`. Use `bun ci` in CI so dependency installation
fails rather than changing an absent or stale lock file.

Bun does not execute arbitrary dependency lifecycle scripts. If a dependency
genuinely requires one, inspect the blocked scripts with `bun pm untrusted` and
trust only the specific package with `bun pm trust <package>`. Do not broadly
disable this protection. Bun also loads `.env` files automatically, so the
template ignores local variants while allowing `.env.example` and
`.env.template` to be committed.

These choices follow Bun's official documentation for
[`bun init`](https://bun.com/docs/runtime/templating/init),
[TypeScript configuration](https://bun.com/docs/typescript),
[lock files](https://bun.com/docs/pm/lockfile), and
[frozen CI installs and trusted dependencies](https://bun.com/docs/pm/cli/install).
Because the runtime is installed by Nix, update the Nixpkgs input and commit the
resulting `flake.lock` instead of running `bun upgrade`.

Like the other generic shells, the Bun template does not inject native
libraries. Add build tools such as `pkgs.pkg-config` or `pkgs.python3` to
`nativeBuildInputs`, and linked libraries such as `pkgs.openssl` to
`buildInputs`, only when the project requires them.

The Node template uses the same shell for conventional frontend and Chrome
Extension development. Both workflows use Node.js and pnpm at build time;
Vite, WXT, TypeScript, ESLint, framework integrations, and application
dependencies belong in `package.json` and `pnpm-lock.yaml`.

Initialize the shared Node environment with:

```bash
nix-direnv node
```

Then choose the project scaffold:

```bash
# Conventional frontend; choose React, Vue, Svelte, or another offered template.
pnpm create vite .

# Chrome Extension; choose Vanilla, React, Vue, Svelte, or Solid.
pnpm dlx wxt@latest init . --pm pnpm
```

Commit the generated `package.json` and `pnpm-lock.yaml`. Keep the project
tooling local and run it through package scripts or `pnpm exec`. The flake owns
Node.js, pnpm, and any required native tools or libraries. The lock file owns
the JavaScript dependency graph. This follows the
[Nixpkgs JavaScript guidance](https://nixos.org/manual/nixpkgs/unstable/#javascript)
to preserve the upstream package manager and lock file.
[Vite documents `pnpm create vite`](https://vite.dev/guide/), while
[WXT documents `pnpm dlx wxt@latest init`](https://wxt.dev/guide/installation.html)
and [uses Vite internally](https://wxt.dev/guide/essentials/config/vite).

There is no `node-extension` selector analogous to `rust-nightly`: Rust nightly
changes the compiler toolchain, whereas Vite and WXT are project dependencies
running on the same Node.js shell. Add another Node dev shell only when a
project genuinely needs a different Node major version or platform SDK.

For direnv:

```bash
echo "use flake" > .envrc
direnv allow
```

After the Darwin configuration has installed the custom Zsh functions,
`nix-direnv [template]` combines those steps. In a directory without
`flake.nix`, it initializes `~/.nix#<template>` (default: `hello`), creates a
basic `.envrc` and `flake.lock`, stages those generated files, and allows
direnv. If it also initializes Git, it creates an initial commit when Git
identity is configured; an existing repository is never automatically
committed. Use `nix-direnv rust` for the default stable shell. The convenience
selector `nix-direnv rust-nightly` initializes the same Rust template but writes
`use flake .#nightly` to a new `.envrc`. An existing `.envrc` is never
overwritten.

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
| Home Manager and per-user Git settings | `nix-darwin/flake-home.nix` |
| Homebrew casks | `nix-darwin/flake-brew.nix` |
| WeType enablement | `nix-darwin/flake-brew.nix` |
| WeType packaging and lifecycle | [`futuping/brew-nix-extra`](https://github.com/futuping/brew-nix-extra) |
| Mac App Store application IDs | `nix-darwin/flake-mas.nix` |
| Fonts | `nix-darwin/flake-fonts.nix` |
| Template names and paths | `flake.nix` |
| Development environments | `nix-dev/<template>/flake.nix` |
| Repository validation | `scripts/check` |
