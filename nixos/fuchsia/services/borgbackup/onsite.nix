{
  config,
  pkgs,
  ...
}: let
  hostname = config.networking.hostName;
in {

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

    preHook = /* sh */ ''
      # Clean up orphaned snapshots from failed runs (crash/power loss)
      [ -d "/btrfs-subvolumes/hm-sajenim" ] && \
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
          "/btrfs-subvolumes/hm-sajenim" 2>/dev/null || true

      # Create read-only BTRFS snapshot for backup
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
        "/home/sajenim" "/btrfs-subvolumes/hm-sajenim"
    '';

    # Backup explicit home directories and persistent files
    paths = [
      # Home directories (valuable user data only)
      "/btrfs-subvolumes/hm-sajenim/Documents"
      "/btrfs-subvolumes/hm-sajenim/Pictures"
      "/btrfs-subvolumes/hm-sajenim/Videos"
      "/btrfs-subvolumes/hm-sajenim/Music"
      "/btrfs-subvolumes/hm-sajenim/Downloads"
      "/btrfs-subvolumes/hm-sajenim/Academics"
      "/btrfs-subvolumes/hm-sajenim/Notes"
      "/btrfs-subvolumes/hm-sajenim/Library"

      # Dotfiles (critical user configuration)
      "/btrfs-subvolumes/hm-sajenim/.ssh"
      "/btrfs-subvolumes/hm-sajenim/.gnupg"

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

    postHook = /* sh */ ''
      # Clean up snapshots after successful backup
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
        "/btrfs-subvolumes/hm-sajenim"
    '';

    # Onsite repository configuration (backup to viridian over SSH)
    repo = "ssh://viridian.home.arpa/srv/borg-repo/${hostname}";

    # No encryption for onsite backups (physical security assumed)
    encryption.mode = "none";

    environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";

    compression = "zstd,9";
    startAt = "hourly";

    # Ensure backup runs on wake if system was asleep
    persistentTimer = true;

    # Match snapper retention policy
    prune.keep = {
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };
  };
}
