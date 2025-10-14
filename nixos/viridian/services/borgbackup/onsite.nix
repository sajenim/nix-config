{
  config,
  pkgs,
  ...
}: let
  hostname = config.networking.hostName;
in {
  # Mount the data drive borg-repo subvolume for local backups
  fileSystems."/srv/borg-repo" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
    options = [
      "subvol=borg-repo"
      "compress=zstd"
    ];
  };

  # Create staging directory before borg service starts
  systemd.tmpfiles.rules = [
    "d /btrfs-subvolumes 0755 root root -"
  ];

  # Configure service to wait for completion before marking as active
  systemd.services."borgbackup-job-onsite" = {
    serviceConfig = {
      Type = "oneshot";
    };
  };

  services.borgbackup.jobs."onsite" = {
    # Allow writing to staging directory
    readWritePaths = [ "/btrfs-subvolumes" ];

    preHook = let
      subvolumes = [
        "srv-containers"
        "srv-forgejo"
        "srv-lighttpd"
        "srv-minecraft"
        "srv-opengist"
      ];
    in /* sh */ ''
      # Clean up orphaned snapshots from failed runs (crash/power loss)
      for subvol in ${toString subvolumes}; do
        [ -d "/btrfs-subvolumes/$subvol" ] && \
          ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
            "/btrfs-subvolumes/$subvol" 2>/dev/null || true
      done

      # Create read-only BTRFS snapshots for backup
      for subvol in ${toString subvolumes}; do
        case "$subvol" in
          srv-containers) src="/srv/multimedia/containers" ;;
          srv-*) src="/srv/''${subvol#srv-}" ;;
        esac

        ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
          "$src" "/btrfs-subvolumes/$subvol"
      done
    '';

    # Backup staging snapshots and explicit persistent files
    paths = [
      "/btrfs-subvolumes/srv-containers"
      "/btrfs-subvolumes/srv-forgejo"
      "/btrfs-subvolumes/srv-lighttpd"
      "/btrfs-subvolumes/srv-minecraft"
      "/btrfs-subvolumes/srv-opengist"

      # Persistent files (actual storage location)
      "/persist/etc/machine-id"
      "/persist/etc/ssh/ssh_host_rsa_key"
      "/persist/etc/ssh/ssh_host_rsa_key.pub"
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/persist/etc/ssh/ssh_host_ed25519_key.pub"

      # Persistent directories (actual storage location)
      "/persist/var/lib/bluetooth"
      "/persist/var/lib/nixos"
      "/persist/var/lib/private"
      "/persist/etc/NetworkManager/system-connections"
    ];

    postHook = let
      subvolumes = [
        "srv-containers"
        "srv-forgejo"
        "srv-lighttpd"
        "srv-minecraft"
        "srv-opengist"
      ];
    in /* sh */ ''
      # Clean up snapshots after successful backup
      for subvol in ${toString subvolumes}; do
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
          "/btrfs-subvolumes/$subvol"
      done
    '';

    # Local repository configuration
    repo = "/srv/borg-repo/${hostname}";

    # No encryption for local backups (physical security assumed)
    encryption.mode = "none";

    compression = "zstd,9";
    startAt = "hourly";

    # Match snapper retention policy
    prune.keep = {
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };
  };
}
