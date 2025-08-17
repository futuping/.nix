# Nix Flake Templates

A collection of Nix flake templates for different development environments and system configurations.

## Overview

This repository provides a collection of Nix flake templates for different development environments:

- **nix-darwin** - Comprehensive macOS system configuration with nix-darwin, Fish shell, Homebrew integration, and npm packages
- **rust** - Rust development environment with stable and nightly toolchains, including WebAssembly support
- **hello** - Basic flake template for simple projects

## Templates

```
├── flake.nix           # Main flake defining all templates
├── nix-darwin/         # macOS system configuration template
│   ├── flake.nix       # Main Darwin system flake
│   ├── flake-darwin.nix # Core system settings and packages
│   ├── flake-brew.nix  # Homebrew Cask integration
│   └── flake-npm.nix   # Node.js/npm package management
├── rust/               # Rust development template
│   └── flake.nix       # Rust toolchain with stable/nightly shells
└── hello/              # Basic template
    └── flake.nix       # Simple development shell
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
```

## Template Details

### nix-darwin Template

A comprehensive macOS system configuration with:
- **Core system settings** - macOS defaults, services, and essential packages
- **Fish shell environment** - Custom functions and interactive shell configuration
- **Homebrew integration** - GUI applications via brew-nix
- **Node.js ecosystem** - npm packages through npm-nix
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
- Custom package overrides and configurations

**Node.js Ecosystem (flake-npm.nix)**
- npm packages via npm-nix integration
- JavaScript development environment
- Node.js-specific configurations

### rust Template

A Rust development environment featuring:
- **Stable and nightly toolchains** - Rust 1.88.0 stable and nightly 2025-05-09
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
- nixfmt-rfc-style, vim, git, nodejs

**Editors & IDEs**
- Visual Studio Code

**Terminal & Productivity**
- Warp Terminal, Raycast

**AI & Coding Assistants**
- Claude Code

**Shell Environment**
- Fish shell with syntax highlighting
- direnv for automatic environment loading

### rust Template Packages

**Rust Toolchains**
- Stable 1.88.0 and Nightly 2025-05-09
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
- **Homebrew apps**: Add casks to `flake-brew.nix`
- **npm packages**: Add to `flake-npm.nix`
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
