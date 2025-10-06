{config, ...}: let
  hostname = config.networking.hostName;
in {
  services.lighttpd = {
    enable = true;
    port = 5624;
    document-root = "/srv/lighttpd/sajenim.dev";
  };

  services.traefik.dynamicConfigOptions.http.routers = {
    lighttpd = {
      rule = "Host(`sajenim.dev`)";
      entryPoints = [
        "websecure"
      ];
      service = "lighttpd";
    };
  };

  services.traefik.dynamicConfigOptions.http.services = {
    lighttpd.loadBalancer.servers = [
      {url = "http://127.0.0.1:${toString config.services.lighttpd.port}";}
    ];
  };

  fileSystems."/srv/lighttpd" = {
    device = "/dev/disk/by-label/${hostname}";
    fsType = "btrfs";
    options = [
      "subvol=srv-lighttpd"
      "compress=zstd"
    ];
  };
}
