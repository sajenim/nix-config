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
    "d /.staging-onsite 0755 root root -"
  ];

  services.borgbackup.jobs."onsite" = {
    # Allow writing to staging directory
    readWritePaths = [ "/.staging-onsite" ];

    # Create staging snapshots before backup (independent from offsite)
    preHook = ''
      # Create read-only staging snapshots for each service
      for subvol in containers forgejo lighttpd minecraft opengist; do
        # Map config names to actual subvolume paths
        case "$subvol" in
          containers) src="/srv/multimedia/containers" ;;
          *) src="/srv/$subvol" ;;
        esac

        ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r \
          "$src" "/.staging-onsite/$subvol"
      done
    '';

    # Backup staging snapshots and explicit persistent files
    paths = [
      "/.staging-onsite/containers"
      "/.staging-onsite/forgejo"
      "/.staging-onsite/lighttpd"
      "/.staging-onsite/minecraft"
      "/.staging-onsite/opengist"

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
          "/.staging-onsite/$subvol"
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
