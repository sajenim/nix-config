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
      # Create read-only staging snapshots for home directory
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
        "/home/sajenim" "/subvolumes-offsite/hm-sajenim"
    '';

    # Backup explicit home directories and persistent files
    paths = [
      # Home directories (valuable user data only)
      "/subvolumes-offsite/hm-sajenim/Documents"
      "/subvolumes-offsite/hm-sajenim/Pictures"
      "/subvolumes-offsite/hm-sajenim/Videos"
      "/subvolumes-offsite/hm-sajenim/Music"
      "/subvolumes-offsite/hm-sajenim/Downloads"
      "/subvolumes-offsite/hm-sajenim/Academics"
      "/subvolumes-offsite/hm-sajenim/Notes"
      "/subvolumes-offsite/hm-sajenim/Library"

      # Dotfiles (critical user configuration)
      "/subvolumes-offsite/hm-sajenim/.ssh"
      "/subvolumes-offsite/hm-sajenim/.gnupg"

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
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
        "/subvolumes-offsite/hm-sajenim"
    '';

    # Remote repository configuration
    repo = "li9kg944@li9kg944.repo.borgbase.com:repo";

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
