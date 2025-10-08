{
  config,
  pkgs,
  ...
}: let
  hostname = config.networking.hostName;
in {

  # Create staging directory before borg service starts
  systemd.tmpfiles.rules = [
    "d /subvolumes-onsite 0755 root root -"
  ];

  services.borgbackup.jobs."onsite" = {
    # Allow writing to staging directory
    readWritePaths = [ "/subvolumes-onsite" ];

    # Create staging snapshots before backup (independent from offsite)
    preHook = ''
      # Create read-only staging snapshots for home directory
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
        "/home/sajenim" "/subvolumes-onsite/hm-sajenim"
    '';

    # Backup explicit home directories and persistent files
    paths = [
      # Home directories (valuable user data only)
      "/subvolumes-onsite/hm-sajenim/Documents"
      "/subvolumes-onsite/hm-sajenim/Pictures"
      "/subvolumes-onsite/hm-sajenim/Videos"
      "/subvolumes-onsite/hm-sajenim/Music"
      "/subvolumes-onsite/hm-sajenim/Downloads"
      "/subvolumes-onsite/hm-sajenim/Academics"
      "/subvolumes-onsite/hm-sajenim/Notes"
      "/subvolumes-onsite/hm-sajenim/Library"

      # Dotfiles (critical user configuration)
      "/subvolumes-onsite/hm-sajenim/.ssh"
      "/subvolumes-onsite/hm-sajenim/.gnupg"

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
        "/subvolumes-onsite/hm-sajenim"
    '';

    # Onsite repository configuration (backup to viridian over SSH)
    repo = "ssh://viridian.home.arpa/srv/borg-repo/${hostname}";

    # No encryption for onsite backups (physical security assumed)
    encryption.mode = "none";

    environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";

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
