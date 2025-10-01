{outputs, lib, ...}: {
  imports = [
    ./age.nix
    ./env.nix
    ./nix.nix
    ./ssh.nix
  ];

  nixpkgs = {
    overlays = [
      # Overlays our own flake exports
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
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
    };
  };

  i18n.defaultLocale = "en_AU.UTF-8";
  time.timeZone = "Australia/Perth";

  networking.domain = "kanto.dev";

  hardware.enableRedistributableFirmware = true;
}
