# Darwin Nix Configuration

Comprehensive macOS system configuration using Nix flakes and nix-darwin.

## Overview

This repository provides a modular Darwin system configuration with:
- **Core system settings** - macOS defaults, services, and essential packages
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
sudo darwin-rebuild switch --flake .

# Update flake inputs
nix flake update

# Check configuration
nix flake check
```

## Module Structure

### Core System (flake-darwin.nix)
- System packages and development tools
- Shell configuration (Zsh, direnv)
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

## Requirements

- macOS with Nix installed
- Flakes experimental feature enabled
- nix-darwin for system management
