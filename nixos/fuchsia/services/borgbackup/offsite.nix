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
      # Create read-only staging snapshots for home directory
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
        "/home/sajenim" "/.staging-offsite/home"
    '';

    # Backup explicit home directories and persistent files
    paths = [
      # Home directories (valuable user data only)
      "/.staging-offsite/home/Documents"
      "/.staging-offsite/home/Pictures"
      "/.staging-offsite/home/Videos"
      "/.staging-offsite/home/Music"
      "/.staging-offsite/home/Downloads"
      "/.staging-offsite/home/Academics"
      "/.staging-offsite/home/Notes"

      # Dotfiles (critical user configuration)
      "/.staging-offsite/home/.ssh"
      "/.staging-offsite/home/.gnupg"

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
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete \
        "/.staging-offsite/home"
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

    # Retention policy for daily remote backups
    prune.keep = {
      daily = 7;      # Keep 7 daily backups (1 week)
      weekly = 4;     # Keep 4 weekly backups (1 month)
      monthly = 12;   # Keep 12 monthly backups (1 year)
    };
  };
}
