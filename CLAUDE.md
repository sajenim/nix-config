# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS and Home Manager configuration using flakes architecture, managing two hosts (`fuchsia` and `viridian`) with declarative system and user configurations.

## Common Development Commands

### System Management
- `just build <hostname>` - Build system and home-manager configuration without switching
- `just switch <hostname>` - Build and switch to new system and home-manager configuration (requires sudo)
- `just deploy <hostname>` - Deploy configuration to remote host

**Note**: Home Manager is configured as a NixOS module, so `just build/switch` commands handle both system and user configurations together.

### Nix Operations
- `nix build` - Build packages defined in flake
- `nix fmt` - Format Nix files using alejandra formatter
- `nix flake update` - Update all flake inputs

### Development Environment
- `nix develop` - Enter development shell with `just` available
- `nix-shell` - Legacy shell environment

## Architecture

### Flake Structure
- **Main flake inputs**: nixpkgs (stable/unstable), home-manager, agenix/agenix-rekey, external configs
- **Outputs**: NixOS configurations, Home Manager configurations, packages, overlays, modules
- **Host configurations**: `fuchsia` (desktop) and `viridian` (server)

### Directory Organization
- `nixos/` - System-level configurations
  - `common/global/` - Shared system configuration (nix settings, secrets, SSH)
  - `common/users/` - User account definitions
  - `common/optional/` - Optional system features (yubikey, persistence)
  - `<hostname>/` - Host-specific configurations and services
- `home-manager/` - User environment configurations
  - `sajenim/features/` - Modular user features (cli, desktop, editors, games)
  - `sajenim/global/` - Base user configuration
- `modules/` - Custom NixOS and Home Manager modules
- `pkgs/` - Custom package definitions
- `overlays/` - Package modifications and patches

### Key Features
- **Ephemeral BTRFS**: Root filesystem is recreated on boot with opt-in persistence
- **Secret Management**: agenix for encrypted secrets, rekeyed with YubiKey
- **Modular Design**: Features organized as importable modules
- **Custom Packages**: External configurations (nixvim, xmonad-config) as flake inputs

### Host Profiles
- **fuchsia**: Desktop workstation with X11, gaming, development tools
- **viridian**: Server with multimedia stack (*arr services), web services, containers

### Service Management
- Services defined in `nixos/<hostname>/services/` and `nixos/<hostname>/multimedia/`
- Docker containers managed through `virtualisation.oci-containers`
- Traefik reverse proxy with automatic HTTPS
- Borgbackup for persistent data

### Configuration Patterns
- All `.nix` files use `default.nix` for module entry points
- Configurations use explicit imports for modular composition
- Host-specific and shared configurations clearly separated
- External dependencies managed through flake inputs