{
  config,
  pkgs,
  ...
}: {
  # Create staging directory before borg service starts
  systemd.tmpfiles.rules = [
    "d /btrfs-subvolumes 0755 root root -"
  ];

  # Wait for onsite backup to complete before starting offsite
  systemd.services."borgbackup-job-offsite" = {
    wants = ["borgbackup-job-onsite.service"];
    after = ["borgbackup-job-onsite.service"];
    serviceConfig = {
      Type = "oneshot";
    };
  };

  services.borgbackup.jobs."offsite" = {
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

    # Remote repository configuration
    repo = "r7ag7x1w@r7ag7x1w.repo.borgbase.com:repo";

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.age.secrets.borgbackup.path}";
    };

    environment = {
      BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
    };

    compression = "zstd,9";
    startAt = "daily"; # Daily at midnight

    # Retention policy for daily remote backups
    prune.keep = {
      daily = 7;      # Keep 7 daily backups (1 week)
      weekly = 4;     # Keep 4 weekly backups (1 month)
      monthly = 12;   # Keep 12 monthly backups (1 year)
    };
  };
}
