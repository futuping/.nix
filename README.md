# .nix

Personal macOS configuration and development templates for Apple Silicon.

## System

The configuration targets `MacBook-Pro` (`aarch64-darwin`) at `~/.nix`.
Before using it on another machine, review `machine` in
[`nix-darwin/flake.nix`](nix-darwin/flake.nix) and the enabled modules.

With Nix and nix-darwin installed, validate and activate:

```sh
~/.nix/scripts/check
sudo -H darwin-rebuild switch \
  --flake "$HOME/.nix/nix-darwin#MacBook-Pro" --no-update-lock-file
```

To update dependencies first:

```sh
nix flake update --flake "$HOME/.nix/nix-darwin"
git -C "$HOME/.nix" diff -- nix-darwin/flake.lock
```

Review the lock changes, then validate and activate as above. The `nix-rebuild`
Zsh helper also updates inputs, but deletes old generations and runs garbage
collection after activation, reducing rollback options.

On macOS, garbage collection runs in the foreground as root with `--store local`
so it can use the terminal's App Management permission. Old user generations
are pruned separately as the current user. If cleanup fails with `Operation not
permitted` on an `.app`, enable the terminal under System Settings → Privacy &
Security → App Management, then retry cleanup without updating or rebuilding:

```sh
sudo -H nix-collect-garbage --store local
```

`scripts/check` checks formatting, flake evaluation, Zsh syntax, MAS regression
cases, and development templates. Template checks require network access to
resolve inputs; they do not save lock files.

## Configuration

| Change | File |
| --- | --- |
| Host, platform, inputs, modules | [flake.nix](nix-darwin/flake.nix) |
| Nixpkgs packages | [flake-nixpkgs.nix](nix-darwin/flake-nixpkgs.nix) |
| Homebrew casks, including `search` | [flake-brew.nix](nix-darwin/flake-brew.nix) |
| Independent application packages | [flake-packages.nix](nix-darwin/flake-packages.nix) |
| App Store apps, including Shadowrocket and Xcode | [flake-mas.nix](nix-darwin/flake-mas.nix) |
| macOS defaults, Nix settings, fonts, Zsh | [flake-darwin.nix](nix-darwin/flake-darwin.nix) |
| Home Manager, Git, GitHub CLI, agent links | [flake-home.nix](nix-darwin/flake-home.nix) |
| Template registry and environments | [flake.nix](flake.nix), [nix-dev/](nix-dev/) |

App Store cleanup is enabled: apps absent from both `programs.mas.packages`
and `homebrew.masApps` are removed during activation. The local MAS patch
ignores diagnostic rows and skips cleanup when listing fails.

Application sources and overlays are pinned in `nix-darwin/flake.lock`.
Keep package selections in the corresponding files above.

### WordCraft and Codex

The `wordcraft` Cask provides the desktop app; the independent
`wordcraft-cli` package provides document conversion, scripted editing, and
the headless MCP server. The CLI is selected in `flake-packages.nix`.

To use the CLI before the next system activation, resolve it through the
existing system lock:

```sh
nix run --no-update-lock-file --inputs-from "$HOME/.nix/nix-darwin" \
  nix-packages#wordcraft-cli -- --version
```

Register the same pinned package with Codex:

```sh
codex mcp add wordcraft -- /run/current-system/sw/bin/nix run \
  --no-update-lock-file --inputs-from "$HOME/.nix/nix-darwin" \
  nix-packages#wordcraft-cli -- mcp --author Codex
```

The absolute Nix command also works when the desktop app's `PATH` differs
from an interactive shell. This adds a user-level entry to
`~/.codex/config.toml`; it does not hand ownership of that file to Home Manager.
Set `startup_timeout_sec = 60` in `[mcp_servers.wordcraft]` to allow Nix to
resolve or fetch the locked package, then restart the Codex client.

The server runs without a window. `--author Codex` names revisions and
comments; enable tracked changes per document with `review.trackChanges`
and `{"value": true}`. It does not enable tracking automatically.

## Development

Templates: `rust`, `swift`, `go`, `python` (uv), `node` (pnpm), `bun`, `hello`,
and `nix-darwin`. Development shells target `aarch64-darwin`.

In Zsh after system activation, initialize an environment with an explicit target:

```sh
mkdir my-project && cd my-project
nix-direnv rust
direnv exec . rustc --version
```

The helper creates and stages environment files, preserves an existing `.envrc`,
and enables direnv. It may create an initial commit in a new repository.
Use `direnv exec . <command>` or `nix develop` to load the environment.

Nix owns toolchains and native libraries; project manifests own application
dependencies. Preserve existing version and package-manager constraints, and
commit both Nix and language lock files. Go uses `GOTOOLCHAIN=local`; Python
uses the Nix interpreter with automatic downloads disabled.

### Swift and native macOS development

The `swift` template provides Swift, SwiftPM, SourceKit-LSP, `swift-format`,
and the macOS SDK through Nix. Its checked-in lock starts from the system's
locked Nixpkgs revision; projects inherit that lock and can update it
independently. Swift dependencies stay in `Package.swift` and `Package.resolved`.

```sh
cd ~/jevify
nix-direnv swift
direnv exec . swift --version
direnv exec . swift package --version
nix flake check --no-update-lock-file
```

The shell binds both the source and package-manifest compiler to Nix Swift,
uses the Nix SDK, and clears inherited Swift toolchain overrides. Run builds
with `direnv exec . swift build` and tests with `direnv exec . swift test`.
The default deployment target follows the selected Nixpkgs platform (currently
macOS 14.0); the selected SDK is macOS 26.5. SDK version and deployment target
serve different purposes. Set the same minimum macOS version in the project's
`Package.swift` `platforms` declaration; SwiftPM uses that declaration to
choose its compilation target.

The template checks compile a dependency-free SwiftPM program and a small
SwiftUI/AppKit library without opening a window. These checks do not establish
that a complete application, Xcode previews, or Xcode UI tests work. Run them
after provisioning the environment. To inspect the configuration without
building checks, use `nix flake check --no-build --no-update-lock-file`.

Full Xcode is declared separately in `nix-darwin/flake-mas.nix`. That App Store
ID does not pin a release. As of 2026-10-04, Apple's
[compatibility table](https://developer.apple.com/xcode/system-requirements/)
lists Xcode 27 as requiring macOS 26.6 or later, while Xcode 26.6 supports
macOS 26.2 through 26.x. The current machine is on macOS 26.5.2. MAS cannot
be relied on to install a specific older compatible release unattended, and
the MAS activation module tolerates installation failures. A successful
rebuild therefore does not prove Xcode was installed.

For the current OS, obtain a compatible release such as Xcode 26.6 from
[Apple Developer Downloads](https://developer.apple.com/download/all/?q=Xcode%2026.6);
Apple account authentication and any first-launch setup remain manual.
Alternatively, a future OS upgrade can make the App Store release compatible.
The Nix shell deliberately points `DEVELOPER_DIR` at its own SDK; Apple IDE
tools must use the installed Xcode developer directory explicitly. Do not
replace the project's Nix compiler with Xcode's Swift implicitly.

## Agent instructions

Edit [the shared AGENTS.md](nix-darwin/dotfiles/agents/AGENTS.md).
Home Manager links it to `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`.
Preserve those links; content edits apply to new sessions without a rebuild.
