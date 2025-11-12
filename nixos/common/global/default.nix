# Global NixOS configuration shared across all hosts.
# This module provides base system settings, nixpkgs configuration, and core imports
# that every host in this configuration inherits.
{outputs, lib, ...}: {
  imports = [
    ./age.nix # Secret management with agenix
    ./env.nix # Environment variables and shell configuration
    ./nix.nix # Nix daemon settings, features, and garbage collection
    ./ssh.nix # SSH server configuration and authorized keys
  ];

  # Nixpkgs configuration - applies overlays and sets package acceptance policy
  nixpkgs = {
    # Apply custom overlays to extend/modify the package set
    overlays = [
      # Overlays our own flake exports
      outputs.overlays.additions      # Custom packages from pkgs/
      outputs.overlays.modifications  # Package patches and modifications
      outputs.overlays.unstable-packages # Unstable channel packages
    ];

    config = {
      # Default to free software only - unfree packages must be explicitly allowed
      allowUnfree = false;

      # Centralized unfree package allowlist for NixOS system configuration.
      # Note: nixpkgs.config.allowUnfreePredicate doesn't merge across modules - only the
      # last definition wins. To maintain explicit control over unfree packages, we list
      # all allowed packages here rather than scattering predicates across system modules.
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Gaming
          "steam"
          "steam-unwrapped"
          # Services
          "minecraft-server"
        ];

      # Allow specific packages with known CVEs when required by dependencies.
      # Only add packages here when no secure alternative exists.
      permittedInsecurePackages = [
        "mbedtls-2.28.10" # required for orca-slicer
      ];
    };
  };

  # Localization settings - Australian English locale and Perth timezone
  i18n.defaultLocale = "en_AU.UTF-8";
  time.timeZone = "Australia/Perth";

  # Network configuration - default domain for host FQDNs
  networking.domain = "kanto.dev";

  # Enable non-free firmware for hardware compatibility (WiFi, GPU drivers, etc.)
  hardware.enableRedistributableFirmware = true;
}
