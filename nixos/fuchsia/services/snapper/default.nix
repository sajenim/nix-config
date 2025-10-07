{...}: {
  # Configure snapper for automated snapshots
  # Snapshots stored in nested .snapshots subvolume within home directory
  services.snapper = {
    configs = {
      # Home directory for user sajenim
      home = {
        SUBVOLUME = "/home/sajenim";
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
    };
  };
}
