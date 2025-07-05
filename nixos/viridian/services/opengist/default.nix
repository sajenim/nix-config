{...}: let
  port = "6157";
in {
  # OpenGist service configuration
  virtualisation.oci-containers.containers = {
    opengist = {
      image = "ghcr.io/thomiceli/opengist:1.10";
      ports = [
        "${port}:${port}"
      ];
      volumes = [
        "/var/lib/opengist:/opengist"
      ];
      # Environment variables for OpenGist
      environment = {
        PUID = "1000";
        PGID = "100";
        # Custom OpenGist configuration
        OG_CUSTOM_LOGO = "pikachu.png";
        OG_CUSTOM_FAVICON = "pokeball.png";
        OG_CUSTOM_NAME = "PokeGist";
        # Disable SSH Git support
        OG_SSH_GIT_ENABLED = "false";
      };
    };
  };

  # Traefik configuration
  services.traefik.dynamicConfigOptions.http = {
    # OpenGist Router
    routers.opengist = {
      rule = "Host(`ps7e.xyz`)";
      entryPoints = [
        "websecure"
      ];
      service = "opengist";
    };
    # OpenGist Service
    services.opengist = {
      loadBalancer.servers = [
        {url = "http://127.0.0.1:${port}";}
      ];
    };
  };

  # Persist data for OpenGist
  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/opengist";
        user = "sajenim";
        group = "users";
      }
    ];
  };

  # Activation script to create symlinks for custom assets
  system.activationScripts.opengist-symlink = ''
    cp ${toString ./assets/pikachu.png} /var/lib/opengist/custom/pikachu.png
    cp ${toString ./assets/pokeball.png} /var/lib/opengist/custom/pokeball.png
  '';
}
