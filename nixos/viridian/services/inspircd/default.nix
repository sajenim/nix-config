{...}: {
  services.inspircd = {
    enable = true;
    config = builtins.readFile ./inspircd.conf;
  };

  # Ensure log directory exists
  systemd.services.inspircd.serviceConfig.LogsDirectory = "inspircd";

  environment.etc = {
    "inspircd/inspircd.motd".source = ./inspircd.motd;
  };
}
