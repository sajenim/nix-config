# Centralized secret definitions
{
  config,
  lib,
  ...
}: let
  hostname = config.networking.hostName;
in {
  age.secrets = lib.mkMerge [
    # fuchsia secrets
    (lib.mkIf (hostname == "fuchsia") {
      borgbackup = {
        rekeyFile = ./secrets/borgbackup-fuchsia.age;
      };

      google-vision = {
        rekeyFile = ./secrets/google-vision.age;
        owner = "sajenim";
        group = "users";
      };
    })

    # viridian secrets
    (lib.mkIf (hostname == "viridian") {
      borgbackup = {
        rekeyFile = ./secrets/borgbackup-viridian.age;
      };

      crowdsec-enrollment = {
        rekeyFile = ./secrets/crowdsec-enrollment.age;
        owner = "crowdsec";
        group = "crowdsec";
      };

      traefik = {
        rekeyFile = ./secrets/traefik.age;
        owner = "traefik";
        group = "traefik";
      };
    })
  ];
}
