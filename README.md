# Nix Configuration Repository

A modular Nix configuration repository containing system configuration and development environment templates.

## Overview

This repository is organized into two main parts:

### nix-darwin - System Configuration
Comprehensive macOS system configuration with nix-darwin, Fish shell, Homebrew integration, and Mac App Store support.

### nix-dev - Development Templates
A collection of development environment templates:
- **rust** - Rust development environment with stable and nightly toolchains, including WebAssembly support
- **hello** - Basic flake template for simple projects

## Repository Structure

```
├── flake.nix           # Main flake defining all templates
├── nix-darwin/         # macOS system configuration
│   ├── flake.nix       # Main Darwin system flake
│   ├── flake.lock      # Locked dependency versions
│   ├── flake-darwin.nix # Core system settings and packages
│   ├── flake-brew.nix  # Homebrew Cask integration
│   └── flake-mas.nix   # Mac App Store integration
└── nix-dev/            # Development environment templates
    ├── flake.nix       # Development templates flake
    ├── rust/           # Rust development template
    │   └── flake.nix   # Rust toolchain with stable/nightly shells
    └── hello/          # Basic template
        └── flake.nix   # Simple development shell
```

## Quick Start

### For nix-darwin Template

```bash
# Clone and apply system configuration
git clone https://github.com/futuping/.nix.git
sudo darwin-rebuild switch --flake .nix/nix-darwin#MacBook-Air

# Update flake inputs and rebuild (using custom function)
nix-rebuild

# Initialize a new development environment
nix-direnv [template-name]
```

### Using Templates

```bash
# Initialize a new project with a template (using local cloned repo)
nix flake init --template .nix#nix-darwin
nix flake init --template .nix#rust
nix flake init --template .nix#hello

# Or use development templates directly
nix flake init --template .nix/nix-dev#rust
nix flake init --template .nix/nix-dev#hello
```

## Template Details

### nix-darwin Template

A comprehensive macOS system configuration with:
- **Core system settings** - macOS defaults, services, and essential packages
- **Fish shell environment** - Custom functions and interactive shell configuration
- **Homebrew integration** - GUI applications via brew-nix
- **Mac App Store integration** - Automated installation of App Store applications
- **Development tools** - Editors, terminals, and productivity applications

#### Custom Fish Functions

The nix-darwin template includes two custom Fish shell functions:

**`nix-direnv [template]`**
- Initializes a direnv flake environment with optional template support
- Creates `flake.nix` from FlakeHub templates (defaults to "empty")
- Sets up `.envrc` with `use flake`
- Automatically allows direnv and loads the environment

**`nix-rebuild`**
- Streamlined system rebuild process
- Updates Nix flake inputs
- Rebuilds Darwin system configuration
- Performs garbage collection
- Provides clear status feedback with emojis

#### Module Structure

**Core System (flake-darwin.nix)**
- System packages and development tools
- Fish shell configuration with custom functions
- direnv integration for automatic environment loading
- macOS system defaults and preferences
- Services (Karabiner Elements)

**Homebrew Integration (flake-brew.nix)**
- GUI applications not available in nixpkgs
- Homebrew Cask management through brew-nix
- Custom package overrides with specific hash configurations for compatibility

**Mac App Store Integration (flake-mas.nix)**
- Framework for automated installation of Mac App Store applications
- Uses `mas` command-line tool for App Store management
- Currently configured but no applications installed (empty applications array)

### rust Template

A Rust development environment featuring:
- **Stable and nightly toolchains** - Rust 1.88.0 stable and nightly (pinned to 2025-05-09)
- **WebAssembly support** - wasm32-unknown-unknown target included
- **Development tools** - rust-analyzer, clippy, rustfmt, cargo-nextest
- **System dependencies** - OpenSSL and pkg-config for native development

### hello Template

A minimal flake template with:
- **Basic development shell** - Git and essential tools
- **Simple package definition** - Hello world package example
- **Clean structure** - Perfect starting point for new projects

## Package Highlights

### nix-darwin Template Packages

**Development Tools**
- nixfmt-rfc-style, vim, git, nodejs, go

**Editors & IDEs**
- Visual Studio Code

**Terminal & Productivity**
- Warp Terminal, Raycast

**AI & Coding Assistants**
- Claude Code

**Homebrew Applications**
- qBittorrent (c0re100 fork) with custom hash override
- Elmedia Player with custom hash override
- Configurable package overrides for compatibility

**Mac App Store Applications**
- Framework configured with `mas` tool
- Currently no applications installed (empty configuration)
- Ready for App Store application IDs when needed

**Shell Environment**
- Fish shell with syntax highlighting
- direnv for automatic environment loading

### rust Template Packages

**Rust Toolchains**
- Stable 1.88.0 and Nightly (pinned to 2025-05-09)
- rust-analyzer, clippy, rustfmt
- cargo-nextest for enhanced testing

**System Dependencies**
- OpenSSL development libraries
- pkg-config for native compilation

### hello Template Packages

**Basic Tools**
- Git version control
- Hello world package example

## Requirements

- Nix package manager with flakes experimental feature enabled
- For nix-darwin template: macOS system
- For rust template: Any system supported by Nix
- For hello template: Any system supported by Nix

## Installation

### General Setup

1. **Install Lix** (Nix-compatible package manager):
   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

   For more installation options, visit: https://lix.systems/install/

2. **Install nix-darwin** (follow the official guide):

   Visit https://github.com/nix-darwin/nix-darwin for detailed installation instructions

3. **Clone this repository**:
   ```bash
   git clone https://github.com/futuping/.nix.git
   ```

### Using nix-darwin Template (Recommended)

1. **Apply the system configuration**:
   ```bash
   sudo darwin-rebuild switch --flake .nix/nix-darwin#MacBook-Air
   ```

2. **Set Fish as default shell**:
   ```bash
   chsh -s /run/current-system/sw/bin/fish
   ```



### Using rust Template

1. **Initialize from template**:
   ```bash
   nix flake init --template .nix#rust
   ```

2. **Setup direnv environment**:
   ```bash
   nix-direnv          # Uses nightly toolchain (default)
   nix-direnv stable   # Uses stable toolchain
   ```

### Using hello Template

1. **Initialize from template**:
   ```bash
   nix flake init --template .nix#hello
   ```

2. **Setup direnv environment**:
   ```bash
   nix-direnv
   ```

## Customization

### nix-darwin Template
- **Add packages**: Edit `environment.systemPackages` in `flake-darwin.nix`
- **Homebrew apps**: Add casks to `flake-brew.nix` (may require custom hash overrides)
- **Mac App Store apps**: Add application IDs to the `applications` array in `flake-mas.nix`
- **Fish functions**: Modify `programs.fish.interactiveShellInit` in `flake-darwin.nix`
- **macOS settings**: Adjust `system.defaults` in `flake-darwin.nix`

### rust Template
- **Change toolchain versions**: Edit `stableToolchain` and `nightlyToolchain` in `flake.nix`
- **Add Rust components**: Modify `commonRustComponents.extensions`
- **Add build targets**: Update `commonRustComponents.targets`
- **Add packages**: Include additional tools in `packages` array

### hello Template
- **Add packages**: Include tools in `buildInputs` array
- **Modify shell hook**: Update the welcome message and add initialization commands
