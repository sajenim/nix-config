{
  config,
  pkgs,
  ...
}: {
  # Encrypted passphrase for offsite borgbackup repository
  age.secrets.borgbackup = {
    rekeyFile = ./passphrase.age;
  };

  # Create staging directory before borg service starts
  systemd.tmpfiles.rules = [
    "d /subvolumes-offsite 0755 root root -"
  ];

  services.borgbackup.jobs."offsite" = {
    # Allow writing to staging directory
    readWritePaths = [ "/subvolumes-offsite" ];

    # Create staging snapshots before backup (independent from onsite)
    preHook = ''
      # Create read-only staging snapshots for each service
      for subvol in srv-containers srv-forgejo srv-lighttpd srv-minecraft srv-opengist; do
        # Map subvolume names to actual paths
        case "$subvol" in
          srv-containers) src="/srv/multimedia/containers" ;;
          srv-*) src="/srv/''${subvol#srv-}" ;;
        esac

        ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
          "$src" "/subvolumes-offsite/$subvol"
      done
    '';

    # Backup staging snapshots and explicit persistent files
    paths = [
      "/subvolumes-offsite/srv-containers"
      "/subvolumes-offsite/srv-forgejo"
      "/subvolumes-offsite/srv-lighttpd"
      "/subvolumes-offsite/srv-minecraft"
      "/subvolumes-offsite/srv-opengist"

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

    # Remove staging snapshots after backup completes
    postHook = ''
      for subvol in srv-containers srv-forgejo srv-lighttpd srv-minecraft srv-opengist; do
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
          "/subvolumes-offsite/$subvol"
      done
    '';

    # Remote repository configuration
    repo = "r7ag7x1w@r7ag7x1w.repo.borgbase.com:repo";

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.age.secrets.borgbackup.path}";
    };

    environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
    compression = "zstd,9";
    startAt = "daily";

    # Ensure backup runs on next boot if system was asleep
    persistentTimer = true;

    # Retention policy for daily remote backups
    prune.keep = {
      daily = 7;      # Keep 7 daily backups (1 week)
      weekly = 4;     # Keep 4 weekly backups (1 month)
      monthly = 12;   # Keep 12 monthly backups (1 year)
    };
  };
}
