{config, ...}: let
  hostname = config.networking.hostName;
in {
  imports = [
    ./jellyfin
    ./lidarr
    ./prowlarr
    ./qbittorrent
    ./radarr
    ./sonarr
  ];

  fileSystems = {
    "/srv/multimedia" = {
      device = "/dev/disk/by-label/multimedia";
      fsType = "ext4";
    };

    "/srv/multimedia/containers" = {
      device = "/dev/disk/by-label/${hostname}";
      fsType = "btrfs";
      options = ["subvol=srv-containers" "compress=zstd"];
    };
  };
}
