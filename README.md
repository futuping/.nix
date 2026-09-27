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
| App Store apps, including Shadowrocket | [flake-mas.nix](nix-darwin/flake-mas.nix) |
| macOS defaults, Nix settings, fonts, Zsh | [flake-darwin.nix](nix-darwin/flake-darwin.nix) |
| Home Manager, Git, GitHub CLI, agent links | [flake-home.nix](nix-darwin/flake-home.nix) |
| Template registry and environments | [flake.nix](flake.nix), [nix-dev/](nix-dev/) |

App Store cleanup is enabled: apps absent from both `programs.mas.packages`
and `homebrew.masApps` are removed during activation. The local MAS patch
ignores diagnostic rows and skips cleanup when listing fails.

Application sources and overlays are pinned in `nix-darwin/flake.lock`.
Keep package selections in the corresponding files above.

## Development

Templates: `rust`, `go`, `python` (uv), `node` (pnpm), `bun`, `hello`,
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

## Agent instructions

Edit [the shared AGENTS.md](nix-darwin/dotfiles/agents/AGENTS.md).
Home Manager links it to `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`.
Preserve those links; content edits apply to new sessions without a rebuild.
