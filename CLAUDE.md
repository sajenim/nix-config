# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Deployment Commands

### Building Configurations
```bash
# Build a NixOS configuration (creates ./result symlink)
just build <hostname>
# or
nixos-rebuild build --flake .#<hostname>

# Build home-manager configuration
home-manager build --flake .#sajenim@<hostname>
```

### Deploying Changes
```bash
# Apply NixOS configuration locally (requires sudo)
just switch <hostname>
# or
sudo nixos-rebuild switch --flake .#<hostname>

# Deploy to remote host
just deploy <hostname>
# or
nixos-rebuild switch --flake .#<hostname> --target-host <hostname> --use-remote-sudo

# Apply home-manager configuration
home-manager switch --flake .#sajenim@<hostname>
```

### Code Quality
```bash
# Format all Nix files using alejandra
nix fmt

# Check flake and evaluate all configurations
nix flake check
```

### Secret Management
```bash
# Rekey secrets using YubiKey (after adding/modifying secrets)
agenix-rekey edit <secret-name>
agenix-rekey rekey
```

## Architecture Overview

### Flake Structure
This is a NixOS flake-based configuration managing two hosts:
- **fuchsia**: Desktop workstation (gaming, development, XMonad)
- **viridian**: Server (multimedia, services, containers)

The flake follows the standard structure from Misterio77's starter configs.

### Configuration Layers

**NixOS System Configuration** (`nixos/`):
```
nixos/
├── common/
│   ├── global/           # Base system config for all hosts
│   │   ├── age.nix      # Agenix secret management with YubiKey
│   │   ├── env.nix      # Environment variables
│   │   ├── nix.nix      # Nix daemon, flakes, garbage collection
│   │   └── ssh.nix      # SSH server config
│   ├── optional/         # Opt-in features
│   │   ├── ephemeral-btrfs.nix  # Impermanence with btrfs root wipe
│   │   ├── persist.nix           # Persistence paths for ephemeral root
│   │   └── yubikey.nix           # YubiKey support
│   └── users/            # User-specific system settings
├── fuchsia/
│   ├── configuration.nix
│   └── services/         # Desktop services (X11, pipewire, flatpak, etc.)
└── viridian/
    ├── configuration.nix
    ├── services/         # Server services (traefik, minecraft, IRC, etc.)
    └── multimedia/       # *arr stack (sonarr, radarr, jellyfin, etc.)
```

**Home-Manager User Configuration** (`home-manager/`):
```
home-manager/sajenim/
├── global/               # Base home config
├── features/             # Modular user features
│   ├── cli/             # Shell, terminal utilities
│   ├── desktop/         # GUI applications, window manager
│   ├── editors/         # Text editors configuration
│   ├── games/           # Gaming-related configs
│   ├── printing/        # Printer utilities
│   └── university/      # Academic tools
├── fuchsia.nix          # Desktop profile
└── viridian.nix         # Server profile (minimal)
```

### Key Architectural Patterns

**Module Organization**: Configuration is split between:
- `nixos/common/global/`: Imported by ALL hosts (mandatory base config)
- `nixos/common/optional/`: Opt-in features imported per-host
- `nixos/<hostname>/`: Host-specific hardware and services
- `home-manager/sajenim/features/`: Composable user environment features

**Imports Pattern**: Each host's `configuration.nix` composes its full system by:
1. Importing `../common/global` (base system)
2. Importing selected `../common/optional/*` modules
3. Importing `../common/users/<username>` (user accounts)
4. Importing host-specific services from `./services/`
5. Setting host-specific options (hostname, firewall, etc.)

**Impermanence**: Uses opt-in persistence with ephemeral btrfs root:
- Root filesystem (`/`) wiped on every boot
- Only `/nix`, `/persist`, and `/boot` survive reboots
- Services must explicitly declare what to persist in `/persist`
- Secrets use persistent SSH keys at `/persist/etc/ssh/` for decryption

**Secret Management**:
- Encrypted with agenix using host SSH keys
- Master key stored on YubiKey for rekeying
- Rekeyed secrets stored in `nixos/common/global/secrets/rekeyed/<hostname>/`
- Decryption happens during system activation using persistent SSH keys

**Overlays**: Applied globally via `nixos/common/global/default.nix`:
- `additions`: Custom packages from `pkgs/`
- `modifications`: Patches to existing packages (e.g., dmenu theming)
- `unstable-packages`: Makes `pkgs.unstable.*` available for newer versions

**Unfree Packages**: Allowlist is centralized in `nixos/common/global/default.nix`
- Default policy: only free software
- Exceptions listed explicitly (steam, minecraft-server)
- Do NOT use `allowUnfreePredicate` in other modules (won't merge)

### Flake Inputs
External dependencies include:
- `nixpkgs` (25.05 stable), `nixpkgs-unstable`
- `home-manager` (follows nixpkgs)
- `agenix`, `agenix-rekey` (secret management)
- `impermanence` (ephemeral root filesystem)
- `crowdsec` (security)
- `nixvim` (personal Neovim config, external flake)
- `xmonad-config` (personal XMonad config, external flake)
- `nix-minecraft` (declarative Minecraft server)

Personal flakes (nixvim, xmonad-config) are maintained in separate repositories
and imported as flake inputs. They are updated independently via `nix flake update`.

## Working with This Configuration

### Adding a New Host
1. Create `nixos/<hostname>/` directory
2. Add `configuration.nix` and `hardware-configuration.nix`
3. Add SSH host keys (ed25519 and RSA) to the host directory
4. Update `flake.nix` to add the new `nixosConfiguration`
5. Configure secrets: update age.rekey to include new host key

### Adding a Service
Services are organized by host in `nixos/<hostname>/services/`:
- Create a subdirectory for complex services (e.g., `traefik/`)
- Each service gets its own `default.nix`
- Import in `nixos/<hostname>/services/default.nix` or `configuration.nix`
- Declare persistence paths if using ephemeral root
- Use agenix for any credentials

### Modifying Packages
- **Custom packages**: Add to `pkgs/` and reference in `pkgs/default.nix`
- **Patching packages**: Add patches to `overlays/patches/`, modify overlay in
  `overlays/default.nix`
- **Unfree packages**: Add to allowlist in `nixos/common/global/default.nix`

### Testing Changes
1. **IMPORTANT**: Stage new files with git before building or checking
   - Nix flakes only evaluate files tracked in git
   - Run `git add <file>` for any new files before `nix flake check` or build
2. Build configuration: `just build <hostname>`
3. Check for evaluation errors: `nix flake check`
4. Review changes before switching
5. Switch: `just switch <hostname>` (local) or `just deploy <hostname>` (remote)

### Managing Secrets
- Secrets are encrypted per-host and stored in
  `nixos/common/global/secrets/rekeyed/<hostname>/`
- Edit secrets: `agenix-rekey edit <secret-name>`
- After editing, rekey all hosts: `agenix-rekey rekey`
- YubiKey required for rekeying operations
- Host SSH keys at `/persist/etc/ssh/` are used for automatic decryption

## Important Conventions

### Network IP Allocation
This infrastructure uses the following IP range scheme to avoid conflicts:

**Allocated Ranges:**
- `192.168.50.0/24` - Home router/main LAN
- `10.1.0.0/24` - Internet sharing from fuchsia (Ethernet to printer)
- `10.2.0.0/24` - Reserved for future internet sharing from another host
- `10.3.0.0/24` - Reserved for future internet sharing from another host
- `10.39.179.0/24` - WireGuard VPN on Raspberry Pi
- `172.17.0.0/16` - Docker default bridge network (viridian)

**Conventions:**
- Internet connection sharing uses `10.N.0.0/24` where N is 1, 2, 3, etc.
- Gateway host is always `10.N.0.1`
- DHCP pools typically use `10.N.0.2` through `10.N.0.10`
- Keep VPN/tunnel ranges in the `10.30.0.0/16` and higher space

### Line Length
Keep all Nix code to a maximum of 100 characters per line for consistency.

### Module Naming
- System-level services: `nixos/<hostname>/services/<service-name>/default.nix`
- User-level features: `home-manager/sajenim/features/<category>/<feature>.nix`

### Persistence Declarations
When adding services to hosts with ephemeral root, declare persistence:
```nix
environment.persistence."/persist" = {
  directories = [
    "/var/lib/service-name"
  ];
  files = [
    "/var/lib/service-name/config.conf"
  ];
};
```

### Comments
This codebase uses structured comments to explain configuration choices:
- Block comments at file top explain module purpose
- Inline comments explain non-obvious configuration decisions
- Group related options with visual separators when helpful
