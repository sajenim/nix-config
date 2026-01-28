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
      "/btrfs-subvolumes/hm-sajenim/Library"

      # Dotfiles (critical user configuration)
      "/btrfs-subvolumes/hm-sajenim/.ssh"
      "/btrfs-subvolumes/hm-sajenim/.gnupg"
      "/btrfs-subvolumes/hm-sajenim/.local/bin"

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

    # Remote repository configuration
    repo = "li9kg944@li9kg944.repo.borgbase.com:repo";

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.age.secrets.borgbackup.path}";
    };

    environment = {
      BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
    };

    compression = "zstd,9";
    startAt = "14:00"; # Daily at 2pm when system is reliably awake

    # Retention policy for daily remote backups
    prune.keep = {
      daily = 7;      # Keep 7 daily backups (1 week)
      weekly = 4;     # Keep 4 weekly backups (1 month)
      monthly = 12;   # Keep 12 monthly backups (1 year)
    };
  };
}
