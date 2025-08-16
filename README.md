# Darwin Nix Configuration

[English](README.md) | [中文](README.zh.md)

Comprehensive macOS system configuration using Nix flakes and nix-darwin with Fish shell integration.

## Overview

This repository provides a modular Darwin system configuration with:
- **Core system settings** - macOS defaults, services, and essential packages
- **Fish shell environment** - Custom functions and interactive shell configuration
- **Homebrew integration** - GUI applications via brew-nix
- **Node.js ecosystem** - npm packages through npm-nix
- **Development tools** - Editors, terminals, and productivity applications

## Architecture

```
├── flake.nix           # Main flake with inputs and system configuration
├── flake-darwin.nix    # Core Darwin system settings and packages
├── flake-brew.nix      # Homebrew Cask integration module
└── flake-npm.nix       # Node.js/npm package management module
```

## Quick Start

```bash
# Apply system configuration
sudo darwin-rebuild switch --flake .nix#MacBook-Air

# Update flake inputs and rebuild (using custom function)
nix-rebuild

# Initialize a new development environment
nix-direnv [template-name]
```

## Custom Fish Functions

This configuration includes two custom Fish shell functions:

### `nix-direnv [template]`
Initializes a direnv flake environment with optional template support:
- Creates `flake.nix` from FlakeHub templates (defaults to "empty")
- Sets up `.envrc` with `use flake`
- Automatically allows direnv and loads the environment

### `nix-rebuild`
Streamlined system rebuild process:
- Updates Nix flake inputs
- Rebuilds Darwin system configuration
- Performs garbage collection
- Provides clear status feedback with emojis

## Module Structure

### Core System (flake-darwin.nix)
- System packages and development tools
- Fish shell configuration with custom functions
- direnv integration for automatic environment loading
- macOS system defaults and preferences
- Services (Karabiner Elements)

### Homebrew Integration (flake-brew.nix)
- GUI applications not available in nixpkgs
- Homebrew Cask management through brew-nix
- Custom package overrides and configurations

### Node.js Ecosystem (flake-npm.nix)
- npm packages via npm-nix integration
- JavaScript development environment
- Node.js-specific configurations

## Included Packages

### Development Tools
- **nixfmt-rfc-style** - Official Nix formatter
- **vim** - Text editor
- **git** - Version control system
- **nodejs** - JavaScript runtime and package manager

### Editors & IDEs
- **vscode** - Visual Studio Code editor

### Terminal & Productivity
- **warp-terminal** - Modern terminal with AI features
- **raycast** - Spotlight replacement and productivity tool

### AI & Coding Assistants
- **claude-code** - Claude AI coding assistant

### Shell Environment
- **fish** - User-friendly shell with syntax highlighting
- **direnv** - Automatic environment loading

## Requirements

- macOS with Nix installed
- Flakes experimental feature enabled
- nix-darwin for system management

## Installation

1. **Install Nix** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Install nix-darwin**:
   ```bash
   nix run nix-darwin -- switch --flake .#MacBook-Air
   ```

3. **Set Fish as default shell**:
   ```bash
   chsh -s /run/current-system/sw/bin/fish
   ```

4. **Start a new terminal session** to use Fish shell with custom functions.

## Customization

- **Add packages**: Edit `environment.systemPackages` in `flake-darwin.nix`
- **Homebrew apps**: Add casks to `flake-brew.nix`
- **npm packages**: Add to `flake-npm.nix`
- **Fish functions**: Modify `programs.fish.interactiveShellInit` in `flake-darwin.nix`
- **macOS settings**: Adjust `system.defaults` in `flake-darwin.nix`
