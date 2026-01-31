# NixOS & Home-Manager Configuration

My [NixOS](https://nixos.org/) and [Home-Manager](https://github.com/nix-community/home-manager) config files.
Based upon [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs).

> This repo is often neglected and doesn't necessarily follow best practices.
> I recommend only using this repo for inspiration and instead use this
> [boilerplate](https://github.com/Misterio77/nix-starter-configs/tree/main/standard)

## Preview
![screenshot](assets/2024-01-18-224416_4480x1440_scrot.png)

## Hosts
* **fuchsia** - Desktop gaming and development machine with full desktop environment
* **viridian** - Server hosting multimedia services, git forge, and various web services

## Features
* __Opt-in persistence with ephemeral btrfs root and 14-day snapshot retention.__
* __Snapper automated snapshots with tiered retention (24h/7d/4w/12m).__
* __Automated borgbackup of mutable service and container data.__
* __Traefik reverse proxy with crowdsec security middleware.__
* __Secrets managed with agenix and rekeyed with yubikey.__
* __Standalone nixvim configuration for neovim.__
* __Custom haskell packages for xmonad & xmobar.__
* __Declarative minecraft server with nix-minecraft.__
* __Media server with typical *arr stack.__
* __Private DNS with .home.arpa for all internal services.__

## Usage
Common tasks are available via the justfile:
```sh
just build <hostname>         # Build configuration without switching
just switch <hostname>        # Build and switch to new configuration
just deploy <hostname>        # Deploy to remote host over SSH
just update                   # Update all flake inputs
just update-input <input>     # Update specific flake input
```

## Installation
```sh
# Prepare disks, create an EFI System partition and Linux Filesystem partition
fdisk /dev/nvme0n1

# Create our filesystems
mkfs.fat -F32 -n ESP /dev/nvme0n1p1
mkfs.btrfs -L ${hostname} /dev/nvme0n1p2
    
# Create our subvolumes
mount /dev/nvme0n1p2 /mnt/btrfs
btrfs subvolume create /mnt/btrfs/{root,nix,persist,swap}
umount /mnt/btrfs

# Prepare for installation
mount -o compress=zstd,subvol={root,nix,persist,swap} /dev/nvme0n1p2 /mnt/{nix,persist,swap}
mount /dev/nvme0n1p1 /mnt/boot

# Clone the configuration files and enter repo
git clone https://github.com/sajenim/nix-config.git && cd nix-config

# Install our system configuration
nixos-install --flake .#hostname
```

## FAQ
* **What is nix?**  
Nix is a tool that takes a unique approach to package management and system configuration.
* **Nix benefits**  
Nix is reproducible, declarative and reliable.
* **Why flakes?**  
Flakes allow you to specify your code's dependencies (e.g. remote Git repositories) in a declarative way,
simply by listing them inside a flake.nix file.

## Credit
### Boilerplate
* [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
### Other Configs
* [fortuneteller2k/nix-config](https://github.com/fortuneteller2k/nix-config)
* [javacafe01/nix-config](https://github.com/javacafe01/nix-config)
