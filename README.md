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
| Primary user | Selected by `machine.userName` | `nix-darwin/flake.nix` |
| Repository path used by Zsh helpers | `~/.nix` | `nix-darwin/flake.nix` |
| Git commit identity | `Tuping Fu <45912467+futuping@users.noreply.github.com>` | `nix-darwin/flake-home.nix` |
| Home Manager state version | `26.05` | `nix-darwin/flake-home.nix` |

Change these values for the target machine. Also review the enabled packages,
services, macOS defaults, casks, App Store applications, and fonts.

Other important assumptions:

- The configuration enables nix-darwin's Nix management with
  `nix.enable = true`; cache settings are declared in `nix.settings`.
- Unfree packages are allowed.
- The configuration expects the repository at `~/.nix` unless
  `machine.configurationDirectory` is changed.
- Home Manager is integrated as a nix-darwin module and owns the primary
  user's global Git configuration.

### Safety notes

- TLS key logging is disabled by default. Run `tls-debug command [arg ...]` to
  enable it for one child process. The command prints the generated key-log
  path; treat that file as sensitive and delete it after debugging.
- The custom `nix-rebuild` Zsh function updates inputs, activates the system,
  deletes old system generations, and runs garbage collection. It requires
  network access, may modify `flake.lock`, and reduces rollback options.
- `programs.mas.cleanup = true` removes installed Mac App Store applications
  that are absent from both `programs.mas.packages` and `homebrew.masApps`.
  Keep every desired App Store application in one of those lists.
  A local compatibility patch accepts only numeric application rows from
  `mas list` and skips cleanup if that query fails. This prevents mas 7's
  empty-list/Spotlight warnings from being treated as applications. The patch
  requires review if an input update changes the affected upstream code.
- Custom Homebrew casks and fonts may have their own license and redistribution
  terms. Verify them before reusing or redistributing this configuration.
- Third-party cask metadata is pinned separately through
  [`futuping/brew-api-extra`](https://github.com/futuping/brew-api-extra) and
  converted with the same brew-nix packaging logic as official casks.
  Package-specific normalization and system lifecycle modules are pinned
  through
  [`futuping/brew-nix-extra`](https://github.com/futuping/brew-nix-extra).
  Its verified updater also maintains the fixed hash for the official Google
  Chrome cask's mutable Stable DMG.
- Non-Homebrew application packages are pinned through
  [`futuping/nix-packages`](https://github.com/futuping/nix-packages). Its
  binary updaters follow official upstream releases, while Neomacs intentionally
  tracks validated development revisions of upstream `main`. The local rebuild
  wrapper receives published revisions through the existing full flake update.
  Neomacs is not selected in the current configuration. When selected by its
  bare package name, it includes a Finder-launchable
  app with text-file associations. Its GitHub CI publishes validated binaries
  to the public `utitsoga` Cachix cache, avoiding a local source build when the
  exact locked outputs are available. The app launcher uses the same pinned
  dependencies as CI even when the consumer follows a different nixpkgs pin.

### Rayburst

Rayburst replaces the former Motrix Next selection in `flake-brew.nix` through
the shared third-party cask module. The catalog pins the explicitly selected
[`4.0.0-beta.2` release](https://github.com/AnInsomniacy/rayburst/releases/tag/v4.0.0-beta.2)
because the upstream Homebrew tap still describes beta.1. Adopting another
release requires a reviewed catalog change and consumer lock update.

The renamed application uses a new bundle identifier and does not import
Motrix Next settings, tasks, or history. Keep existing downloaded files.
Updating this configuration does not activate the system or remove user data.

### Neomacs binary cache

The current configuration declares this optional cache in `nix.settings`.
For a separate host using Determinate Nix, the equivalent additive settings
belong in `/etc/nix/nix.custom.conf` (not its managed `nix.conf`):

```conf
extra-substituters = https://utitsoga.cachix.org
extra-trusted-public-keys = utitsoga.cachix.org-1:vEIve6o6RwvjUotznYxEDqQmBPV8SWaOupBsA2GAq4k=
```

Keep signature checking enabled and retain the default Nix caches. Public
cache reads need neither a token nor a globally installed Cachix CLI.

The GitHub repository owns the cache write secret. CI validates before uploading
Neomacs and its required runtime/IFD outputs; a fresh runner verifies downloads
with all builders disabled. Cache eviction or changed inputs can still cause a
cache miss. Updating a lock or filling a cache does not activate a new system;
`darwin-rebuild switch` remains an explicit installation step.

The current upstream pdump images retain build-environment references, so the
package closure also includes build tools and dependency artifacts. The cache
avoids local compilation but does not itself reduce that existing closure;
cleaning the runtime images is a separate packaging optimization.

## Repository layout

```text
.
├── flake.nix                    # Template registry; defaults to hello
├── scripts/check                # Unified repository validation
├── nix-darwin/
│   ├── flake.nix                # Host, platform, inputs, and module wiring
│   ├── flake.lock               # Locked Darwin dependencies
│   ├── flake-nixpkgs.nix        # Nixpkgs configuration and system packages
│   ├── flake-packages.nix       # Non-Homebrew, non-nixpkgs applications
│   ├── flake-darwin.nix         # macOS defaults, system fonts, and Zsh
│   ├── flake-home.nix           # Home Manager and per-user Git configuration
│   ├── flake-brew.nix           # Homebrew casks
│   └── flake-mas.nix            # Native Mac App Store management
└── nix-dev/
    ├── hello/
    │   ├── flake.nix
    │   └── .gitignore
    ├── rust/
    │   ├── flake.nix
    │   └── .gitignore
    ├── go/
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
| `rust` | Pinned stable Rust shell and target examples |
| `go` | Nix-managed Go shell with gopls and a compiler smoke check |
| `python` | Nix-managed Python 3.12 and uv development shell |
| `bun` | Nix-managed Bun shell for JavaScript and TypeScript projects |
| `node` | Node.js 24 and pnpm 11 shell for frontend and browser-extension development |
| `nix-darwin` | Copy of the macOS configuration |

Development templates expose only `aarch64-darwin`, matching this M1 setup.

The current system package list includes Node.js 24 and Python 3.12 with
PyYAML. Go and Rust remain project-scoped. Long-lived projects should still
use a committed flake or a matching
`nix-dev` template. Simple ad-hoc tasks can use `nix run` or
`nix shell --command`, preferably with an existing locked input, without
creating a new project. Complex or reusable task environments should use a
locked task-local `.codex-env/` or an independent temporary directory,
initialized through `nix-direnv <target>`. Commit each project's `flake.lock`
and language dependency lock files.

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

The Rust template uses rust-overlay's stable toolchain with the minimal profile
and adds the development components explicitly, so it does not install the
offline `rust-docs` component. The committed `flake.lock` pins the selected
Nixpkgs and rust-overlay revisions. Comments beside `rustTargets` show common
macOS, Windows, Linux, iOS, Android, browser WebAssembly, and WASI target
triples. Uncomment only those required by the project.

The generic template deliberately does not inject native libraries. When a
crate actually needs them, add build tools such as `pkgs.pkg-config` to
`nativeBuildInputs` and linked libraries such as `pkgs.openssl` to
`buildInputs` in that project's shell.

The Go template provides the compiler (including `gofmt`) and the `gopls`
language server. Initialize a new environment and module with:

```bash
mkdir my-go-project
cd my-go-project
nix-direnv go
direnv exec . go mod init example.com/my-go-project
```

After adding source files, run `go mod tidy` to resolve dependencies and
`go test ./...` to test the project. Commit `go.mod` and `go.sum` when generated;
Go maintains module requirements and dependency checksums in these files, as
described in its [dependency management guide](https://go.dev/doc/modules/managing-dependencies).
The project `flake.nix` owns Go, gopls, and native dependencies, while
`flake.lock` pins their exact Nixpkgs revision.

The shell sets `GOTOOLCHAIN=local` to use the Nix-provided compiler, following
Go's [toolchain selection rules](https://go.dev/doc/toolchain).
If a module requires a newer Go release, first select a compatible Nix Go
package; update the relevant input and `flake.lock` only if needed.
Add native build tools and libraries for cgo only when a project needs them.
Run `nix flake check` to verify the tooling and
compile and execute a small Go program.

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
committed. Use `nix-direnv rust` for the stable Rust shell. The helper never
overwrites an existing `.envrc`.

## GitHub CLI preferences

Home Manager generates `~/.config/gh/config.yml` from `programs.gh.settings`
in `nix-darwin/flake-home.nix`. The declarations preserve the existing HTTPS
protocol, prompts, editor and pager fallbacks, display preferences, and
`co = pr checkout` alias. The `gh` executable remains in the system package
set; the Home Manager module references the same Nix package.

Edit the Nix settings and activate Home Manager to change these preferences.
The generated file is read-only, so commands such as `gh config set` and
`gh alias set` should not be used to modify the managed configuration.
Home Manager backs up existing unmanaged files with the `.hm-backup` suffix
before taking ownership. For GitHub CLI, this creates
`~/.config/gh/config.yml.hm-backup`. If that backup already exists, activation
stops so it can be preserved before retrying.

Account state and credentials remain local and managed by `gh`; `hosts.yml`
is not declared in Nix. The module's Git credential helper is explicitly
disabled to preserve the existing Git authentication setup. Its legacy
account-migration activation is also disabled because the existing CLI
configuration already uses schema version 1.

## Global agent instructions

The complete shared English policy lives in
[`nix-darwin/dotfiles/agents/AGENTS.md`](nix-darwin/dotfiles/agents/AGENTS.md).
It covers project setup, existing-environment migration, one-off Nix commands,
dependency ownership, and Rust, Go, Python, Node.js, and Bun conventions.

Home Manager deploys `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md` as
out-of-store links to the same source. The source path is derived from
`machine.configurationDirectory`; the module does not hardcode a username.
These are the default agent configuration locations; a custom `CODEX_HOME`
or Claude configuration directory needs a corresponding target adjustment.

After the initial activation, edit the repository source rather than replacing
either entry-point link. New agent sessions read the edited content without
another system rebuild. Git manages the content history; rolling back a Nix
generation does not roll back the mutable instruction source. Preserve any
existing entry-point files before the first deployment.

## Validate and maintain

Run the unified check before activation:

```bash
~/.nix/scripts/check
```

It checks Git whitespace, Nix formatting, the template registry, the complete
Darwin configuration, merged Zsh syntax, MAS activation, and every development
template, including any checks declared by a template.
Development templates currently have no lock files, so their first check needs
network access to resolve inputs; the script does not write those temporary
locks.

The MAS regression check runs generated activation scripts against a fake
`sudo`, covering empty-list diagnostics, malformed rows, failed queries, and
preservation of both native and Homebrew app IDs without changing installed apps:

```bash
nix shell --inputs-from ~/.nix/nix-darwin --no-update-lock-file \
  nixpkgs#python312 nixpkgs#bash --command python3 ~/.nix/scripts/check-mas.py
```

For a rebuild with a trace:

```bash
sudo -H darwin-rebuild switch \
  --flake ~/.nix/nix-darwin#MacBook-Pro \
  --show-trace
```

The custom `nix-rebuild` Zsh function is a convenience wrapper with four
consecutive actions:

1. `nix flake update --flake ~/.nix/nix-darwin`
2. `sudo -H darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Pro`
3. Delete old system generations.
4. Run `nix-collect-garbage -d`.

After activation, the wrapper refreshes the current shell's direnv hook through
`/run/current-system/sw/bin/direnv` before cleanup can remove the old executable.
Other open terminals can refresh their hook with
`eval "$(/run/current-system/sw/bin/direnv hook zsh)"`.

The flake update receives the verified Google Chrome source pin published by
`futuping/brew-nix-extra`. Review and commit any resulting lock-file changes.

Use the separate update and rebuild commands above when old generations must
remain available for rollback.

If direnv does not activate, check the project's `.envrc`, then run
`direnv allow` and `direnv status`.

## Configuration map

| Change | File |
| --- | --- |
| Host, platform, inputs, modules | `nix-darwin/flake.nix` |
| Nixpkgs configuration and system packages | `nix-darwin/flake-nixpkgs.nix` |
| Non-Homebrew, non-nixpkgs package selection | `nix-darwin/flake-packages.nix` |
| Zsh, macOS defaults, system fonts | `nix-darwin/flake-darwin.nix` |
| Home Manager, Git, GitHub CLI preferences, and global agent links | `nix-darwin/flake-home.nix` |
| Shared Codex and Claude Code instructions | `nix-darwin/dotfiles/agents/AGENTS.md` |
| Homebrew casks | `nix-darwin/flake-brew.nix` |
| Rayburst package selection (formerly Motrix Next) | `nix-darwin/flake-brew.nix` |
| WeType enablement | `nix-darwin/flake-brew.nix` |
| Cask normalization and lifecycle | [`futuping/brew-nix-extra`](https://github.com/futuping/brew-nix-extra) |
| Non-Homebrew package definitions and updates | [`futuping/nix-packages`](https://github.com/futuping/nix-packages) |
| Mac App Store application IDs | `nix-darwin/flake-mas.nix` |
| System fonts | `nix-darwin/flake-darwin.nix` |
| Template names and paths | `flake.nix` |
| Development environments | `nix-dev/<template>/flake.nix` |
| Repository validation | `scripts/check` |
