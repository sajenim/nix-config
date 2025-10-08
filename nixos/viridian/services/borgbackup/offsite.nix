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
    "d /.staging-offsite 0755 root root -"
  ];

  services.borgbackup.jobs."offsite" = {
    # Allow writing to staging directory
    readWritePaths = [ "/.staging-offsite" ];

    # Create staging snapshots before backup (independent from onsite)
    preHook = ''
      # Create read-only staging snapshots for each service
      for subvol in containers forgejo lighttpd minecraft opengist; do
        # Map config names to actual subvolume paths
        case "$subvol" in
          containers) src="/srv/multimedia/containers" ;;
          *) src="/srv/$subvol" ;;
        esac

        ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
          "$src" "/.staging-offsite/$subvol"
      done
    '';

    # Backup staging snapshots and explicit persistent files
    paths = [
      "/.staging-offsite/containers"
      "/.staging-offsite/forgejo"
      "/.staging-offsite/lighttpd"
      "/.staging-offsite/minecraft"
      "/.staging-offsite/opengist"

      # Files from persist.nix (restore to /persist)
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"

      # Directories from persist.nix (restore to /persist)
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/private"
      "/etc/NetworkManager/system-connections"
    ];

    # Remove staging snapshots after backup completes
    postHook = ''
      for subvol in containers forgejo lighttpd minecraft opengist; do
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
          "/.staging-offsite/$subvol"
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
