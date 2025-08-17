# ============================================================================
# NODE.JS ECOSYSTEM INTEGRATION
# ============================================================================
# Specialized module for Node.js and JavaScript package management.
# Integrates npm packages into Nix ecosystem through npmpackages bridge.
#
# Key features:
# - Declarative npm package management through Nix
# - Reproducible JavaScript development environments
# - Integration with existing Node.js toolchain
# - Consistent package versioning and dependency resolution
# - Environment-specific configuration management

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Import npmpackages package set with pkgs context
  # npmpackages is a non-flake input providing npm package definitions
  npmPackages = import (inputs.npmpackages + "/npmPackages") {
    inherit pkgs;
    # Provides access to stdenv, nodejs, and other build dependencies
  };
in
{
  # ============================================================================
  # NPM PACKAGE DECLARATIONS
  # ============================================================================
  # Declarative npm package management integrated with system packages
  environment.systemPackages = [
    # Utility libraries
    npmPackages.async-foreach # Asynchronous iteration utility

    # Development and build tools (uncomment as needed)
    # npmPackages.musistudio-claude-code-router     # Claude AI code routing
    # npmPackages.npm4nix                           # npm to Nix converter

    # Common JavaScript utilities (examples)
    # npmPackages.chalk                             # Terminal string styling
    # npmPackages.lodash                            # Utility library
    # npmPackages."@types/node"                     # TypeScript definitions
    # npmPackages."@YOUR_USERNAME/package-name"     # Custom scoped packages
  ];

  # ============================================================================
  # NODE.JS DEVELOPMENT ENVIRONMENT
  # ============================================================================
  # Environment variables and configuration for Node.js development
  # Uncomment and customize as needed for specific development requirements

  # environment.variables = {
  #   # Node.js runtime environment
  #   NODE_ENV = "development";
  #
  #   # npm global package installation directory
  #   NPM_CONFIG_PREFIX = "${config.users.users.${config.system.primaryUser}.home}/.npm-global";
  #
  #   # Additional Node.js configuration
  #   NODE_OPTIONS = "--max-old-space-size=4096";     # Increase memory limit
  #   NPM_CONFIG_FUND = "false";                      # Disable funding messages
  #   NPM_CONFIG_AUDIT = "false";                     # Disable audit warnings
  # };
}
