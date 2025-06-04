{...}: {
  services.murmur = {
    enable = true;
    port = 64738;
    openFirewall = true;
    stateDir = "/var/lib/murmur";

    # Stuff
    registerName = "Kanto Network";
    welcometext = "I choose you!";
  };

  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/murmur";
        user = "murmur";
        group = "murmur";
      }
    ];
  };
}
