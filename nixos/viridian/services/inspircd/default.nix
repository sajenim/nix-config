{...}: {
  services.inspircd = {
    enable = true;
    config = builtins.readFile ./inspircd.conf;
  };

  environment.etc = {
    "inspircd/inspircd.motd".source = ./inspircd.motd;
  };
}
