# Nix Configuration Repository

A modular Nix configuration repository containing system configuration and development environment templates.

## Quick Reference

### Essential Commands

```bash
# Apply system configuration (nix-darwin)
sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air

# Update system and rebuild (using custom Fish function)
nix-rebuild

# Initialize development environment with template
nix-direnv [template-name]

# Initialize project from template
nix flake init --template ~/.nix#[template-name]
```

### Available Templates
- `nix-darwin` - Complete macOS system configuration
- `rust` - Rust development with stable/nightly toolchains
- `python` - Python 3.12 with Pixi package manager
- `node` - Node.js 22 with TypeScript and testing tools
- `hello` - Basic development template

## Overview

This repository is organized into two main parts:

### nix-darwin - System Configuration
Comprehensive macOS system configuration with nix-darwin, Fish shell, Emacs integration, Homebrew integration, and Mac App Store support.

### nix-dev - Development Templates
A collection of development environment templates:
- **rust** - Rust development environment with stable and nightly toolchains, including WebAssembly support
- **python** - Python 3.12 development environment with Pixi package manager and testing tools
- **node** - Node.js 22 development environment with TypeScript, pnpm, and testing frameworks
- **hello** - Basic flake template for simple projects

## Repository Structure

```
├── README.md           # This documentation file
├── flake.nix           # Main flake defining all templates
├── nix-darwin/         # macOS system configuration
│   ├── flake.nix       # Main Darwin system flake
│   ├── flake.lock      # Locked dependency versions
│   ├── flake-darwin.nix # Core system settings, packages, and Fish functions
│   ├── flake-brew.nix  # Homebrew Cask integration with custom overrides
│   └── flake-mas.nix   # Mac App Store integration framework
└── nix-dev/            # Development environment templates
    ├── rust/           # Rust development template
    │   └── flake.nix   # Rust toolchain with stable/nightly shells + WebAssembly
    ├── python/         # Python development template
    │   └── flake.nix   # Python 3.12 with Pixi package manager and testing
    ├── node/           # Node.js development template
    │   └── flake.nix   # Node.js 22 with TypeScript, pnpm, and testing tools
    └── hello/          # Basic template
        └── flake.nix   # Simple development shell with Git
```

## Quick Start

### For nix-darwin Template

```bash
# Clone and apply system configuration
git clone https://github.com/futuping/.nix.git
sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air

# Update flake inputs and rebuild (using custom function)
nix-rebuild

# Initialize a new development environment
nix-direnv [template-name]
```

### Using Templates

```bash
# Initialize a new project with a template (using local cloned repo)
nix flake init --template ~/.nix#nix-darwin
nix flake init --template ~/.nix#rust
nix flake init --template ~/.nix#python
nix flake init --template ~/.nix#node
nix flake init --template ~/.nix#hello

# Or use development templates directly
nix flake init --template ~/.nix/nix-dev#rust
nix flake init --template ~/.nix/nix-dev#python
nix flake init --template ~/.nix/nix-dev#node
nix flake init --template ~/.nix/nix-dev#hello
```

## Template Details

### nix-darwin Template

A comprehensive macOS system configuration with:
- **Core system settings** - macOS defaults, services, and essential packages
- **Fish shell environment** - Custom functions and interactive shell configuration
- **Emacs integration** - Native macOS Emacs with daemon service and convenient aliases
- **Homebrew integration** - GUI applications via brew-nix
- **Mac App Store integration** - Automated installation of App Store applications
- **Development tools** - Editors, terminals, and productivity applications

#### Custom Fish Functions

The nix-darwin template includes two custom Fish shell functions:

**`nix-direnv [template]`**
- Initializes a direnv flake environment with optional template support
- Creates `flake.nix` from local templates (defaults to "hello")
- Sets up `.envrc` with `use flake`
- Automatically allows direnv and loads the environment
- Includes error handling and status feedback with emojis

**`nix-rebuild`**
- Streamlined system rebuild process
- Updates Nix flake inputs for ~/.nix/nix-darwin
- Rebuilds Darwin system configuration
- Performs garbage collection with `nix-collect-garbage -d`
- Includes error handling and status feedback with emojis

#### Module Structure

**Core System (flake-darwin.nix)**
- System packages and development tools
- Fish shell configuration with custom functions and Emacs aliases
- direnv integration for automatic environment loading
- macOS system defaults and preferences
- Services (Karabiner Elements keyboard customization, Emacs daemon)

**System Defaults Configuration:**
- **Dock**: Auto-hide enabled, Notes app in persistent apps
- **Finder**: Column view (clmv) as preferred view style
- **Login Window**: Guest account disabled for security
- **Primary User**: Configured as "admin"

**Homebrew Integration (flake-brew.nix)**
- GUI applications not available in nixpkgs
- Homebrew Cask management through brew-nix
- Custom package overrides with specific hash configurations for compatibility

**Mac App Store Integration (flake-mas.nix)**
- Framework for automated installation of Mac App Store applications
- Uses `mas` command-line tool for App Store management
- Currently configured but no applications installed (empty applications array)

**Emacs Integration**
- **Emacs Package**: Uses emacs-macport for native macOS integration
- **Emacs Service**: Daemon automatically started for fast client connections
- **Convenient Aliases**:
  - `emacs`, `e`, `ec` - Open GUI Emacs client (`emacsclient -c -a 'emacs'`)
  - `et` - Open terminal Emacs client (`emacsclient -t -a 'emacs -nw'`)
- **Fallback Support**: Aliases include fallback to standalone Emacs if daemon unavailable

**Services Configuration**
- **Karabiner Elements**: Advanced keyboard customization service
  - Version pinned to 14.13.0 for stability
  - Enables complex key remapping and shortcuts
  - Automatically started as a system service

### rust Template

A Rust development environment featuring:
- **Stable and nightly toolchains** - Rust 1.88.0 stable and nightly (pinned to 2025-05-09)
- **WebAssembly support** - wasm32-unknown-unknown target included
- **Development tools** - rust-analyzer, clippy, rustfmt, cargo-nextest
- **System dependencies** - OpenSSL and pkg-config for native development

### python Template

A Python development environment featuring:
- **Python 3.12** - Latest stable Python version
- **Pixi package manager** - Modern Python package and environment management
- **Testing framework** - pytest and pytest-cov for comprehensive testing
- **Native compilation support** - gcc and pkg-config for building native extensions

### node Template

A Node.js development environment featuring:
- **Node.js 22** - Latest LTS Node.js version
- **Package manager** - pnpm (npm is included with Node.js)
- **TypeScript support** - TypeScript compiler and ts-node
- **Testing frameworks** - Jest and Mocha for comprehensive testing
- **Native compilation support** - gcc and pkg-config for native modules

### hello Template

A minimal flake template with:
- **Basic development shell** - Git and essential tools
- **Simple package definition** - Hello world package example
- **Clean structure** - Perfect starting point for new projects

## Package Highlights

### nix-darwin Template Packages

**Development Tools**
- nixfmt-rfc-style, git

**Editors & IDEs**
- Emacs (emacs-macport with daemon service)
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
- Fish shell with syntax highlighting and custom functions
- direnv for automatic environment loading
- Emacs aliases for quick editor access

### rust Template Packages

**Rust Toolchains**
- Stable 1.88.0 and Nightly (pinned to 2025-05-09)
- rust-analyzer, clippy, rustfmt included
- cargo-nextest for enhanced testing
- WebAssembly target (wasm32-unknown-unknown) pre-configured

**System Dependencies**
- OpenSSL development libraries
- pkg-config for native compilation

### python Template Packages

**Python Environment**
- Python 3.12 interpreter
- Pixi package manager for modern Python dependency management

**Testing Tools**
- pytest for unit testing
- pytest-cov for test coverage analysis

**Build Tools**
- gcc compiler for native extensions
- pkg-config for library configuration

### node Template Packages

**Node.js Environment**
- Node.js 22 runtime
- pnpm package manager
- TypeScript compiler and ts-node

**Testing Tools**
- Jest testing framework
- Mocha testing framework

**Build Tools**
- gcc compiler for native modules
- pkg-config for library configuration

### hello Template Packages

**Basic Tools**
- Git version control
- Hello world package example

## Requirements

- Nix package manager with flakes experimental feature enabled
- For nix-darwin template: macOS system
- For rust template: Any system supported by Nix
- For python template: Any system supported by Nix
- For node template: Any system supported by Nix
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
   sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air
   ```

2. **Set Fish as default shell**:
   ```bash
   chsh -s /run/current-system/sw/bin/fish
   ```

3. **Emacs Setup** (automatically configured):
   - Emacs daemon service starts automatically
   - Use aliases: `emacs`, `e`, `ec` for GUI, `et` for terminal
   - Emacs server provides fast startup for subsequent sessions



### Using rust Template

1. **Initialize from template**:
   ```bash
   nix flake init --template ~/.nix#rust
   ```

2. **Setup direnv environment**:
   ```bash
   nix-direnv          # Uses nightly toolchain (default)
   nix-direnv stable   # Uses stable toolchain
   ```

### Using python Template

1. **Initialize from template**:
   ```bash
   nix flake init --template ~/.nix#python
   ```

2. **Setup direnv environment**:
   ```bash
   nix-direnv
   ```

### Using node Template

1. **Initialize from template**:
   ```bash
   nix flake init --template ~/.nix#node
   ```

2. **Setup direnv environment**:
   ```bash
   nix-direnv
   ```

### Using hello Template

1. **Initialize from template**:
   ```bash
   nix flake init --template ~/.nix#hello
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
- **Emacs aliases**: Customize Emacs aliases in Fish shell configuration
- **macOS settings**: Adjust `system.defaults` in `flake-darwin.nix`
- **Services**: Enable/disable services like Karabiner Elements or Emacs daemon

### rust Template
- **Change toolchain versions**: Edit `stableToolchain` and `nightlyToolchain` in `flake.nix`
- **Add Rust components**: Modify `commonRustComponents.extensions`
- **Add build targets**: Update `commonRustComponents.targets`
- **Add packages**: Include additional tools in `packages` array

### python Template
- **Change Python version**: Update `python312` to desired version in `flake.nix`
- **Add Python packages**: Include additional packages in `checkInputs` array
- **Add system dependencies**: Include native libraries in `buildInputs`
- **Modify shell hook**: Update the welcome message and add initialization commands

### node Template
- **Change Node.js version**: Update `nodejs_22` to desired version in `flake.nix`
- **Add Node.js packages**: Include additional packages in `packages` array
- **Add system dependencies**: Include native libraries in `buildInputs`
- **Modify shell hook**: Update the welcome message and add initialization commands

### hello Template
- **Add packages**: Include tools in `buildInputs` array
- **Modify shell hook**: Update the welcome message and add initialization commands

## Troubleshooting

### Common Issues

**Flake Lock Issues**
```bash
# Update all flake inputs
nix flake update --flake ~/.nix/nix-darwin

# Update specific input
nix flake lock --update-input nixpkgs --flake ~/.nix/nix-darwin
```

**Homebrew Cask Hash Mismatches**
- Custom hash overrides are provided for qBittorrent and Elmedia Player
- If you encounter hash mismatches with other casks, add similar overrides in `flake-brew.nix`

**Darwin Rebuild Failures**
```bash
# Clean rebuild
sudo darwin-rebuild switch --flake ~/.nix/nix-darwin#MacBook-Air --show-trace

# Check for conflicting processes
sudo launchctl list | grep nix
```

**direnv Not Loading**
```bash
# Manually allow direnv
direnv allow

# Check direnv status
direnv status
```

**Emacs Issues**
```bash
# Restart Emacs daemon
sudo launchctl stop org.nixos.emacs
sudo launchctl start org.nixos.emacs

# Check Emacs daemon status
launchctl list | grep emacs

# Start Emacs manually if daemon fails
/run/current-system/sw/bin/emacs --daemon
```

### Dependency Management

**Flake Inputs**
- All templates use `nixpkgs-unstable` for latest packages
- Dependencies are locked in `flake.lock` files
- Use `nix flake update` to update all dependencies
- Use `nix flake lock --update-input <input>` for specific updates

## Best Practices

### Template Usage
- Always test templates in isolated directories before applying to projects
- Use `nix-direnv` function for quick development environment setup
- Keep `flake.lock` files committed for reproducible builds
- Regularly update flake inputs to get security patches

### System Configuration
- Test nix-darwin changes in a virtual machine first if possible
- Keep backups of working configurations before major updates
- Use the `nix-rebuild` function for streamlined system updates
- Monitor system resources after adding new packages or services

### Development Workflow
1. Initialize project with appropriate template
2. Customize `flake.nix` for project-specific needs
3. Use `direnv` for automatic environment activation
4. Commit both `flake.nix` and `flake.lock` to version control

## Contributing

### Adding New Templates
1. Create new directory under `nix-dev/`
2. Add `flake.nix` with appropriate development environment
3. Update main `flake.nix` to include new template
4. Update this README with template documentation
5. Test template across different systems if possible

### Modifying Existing Templates
1. Test changes thoroughly in isolated environment
2. Update documentation to reflect changes
3. Consider backward compatibility for existing users
4. Update version pins and dependencies as needed
