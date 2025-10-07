{...}: {
  # Configure snapper for automated snapshots
  # Snapshots stored in nested .snapshots subvolumes within each service
  services.snapper = {
    # Enable snapper globally
    configs = {
      # Minecraft server data
      minecraft = {
        SUBVOLUME = "/srv/minecraft";
        ALLOW_USERS = ["sajenim"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        # Tiered retention: 24h + 7d + 4w + 12m = ~1 year of snapshots
        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 12;
        TIMELINE_LIMIT_YEARLY = 0;
      };

      # Container data (jellyfin, arr services, etc)
      containers = {
        SUBVOLUME = "/srv/multimedia/containers";
        ALLOW_USERS = ["sajenim"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 12;
        TIMELINE_LIMIT_YEARLY = 0;
      };

      # Forgejo git forge data
      forgejo = {
        SUBVOLUME = "/srv/forgejo";
        ALLOW_USERS = ["sajenim"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 12;
        TIMELINE_LIMIT_YEARLY = 0;
      };

      # OpenGist pastebin data
      opengist = {
        SUBVOLUME = "/srv/opengist";
        ALLOW_USERS = ["sajenim"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 12;
        TIMELINE_LIMIT_YEARLY = 0;
      };

      # Lighttpd website data
      lighttpd = {
        SUBVOLUME = "/srv/lighttpd";
        ALLOW_USERS = ["sajenim"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 12;
        TIMELINE_LIMIT_YEARLY = 0;
      };
    };
  };
}
