{config, ...}: {
  # Environment variables for ProjectSend
  age.secrets.projectsend = {
    rekeyFile = ./environment.age;
  };

  # Setup for ProjectSend, a file sharing application
  virtualisation.oci-containers.containers = {
    projectsend = {
      image = "linuxserver/projectsend:version-r1720";
      ports = [
        "9684:80"
      ];
      volumes = [
        "/var/lib/projectsend/config:/config"
        "/var/lib/projectsend/data:/data"
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
      };
      extraOptions = [
        "--network=projectsend"
      ];
    };

    # MariaDB container for ProjectSend
    projectsend-mariadb = {
      image = "mariadb:lts-noble";
      volumes = [
        "/var/lib/projectsend/mysql:/var/lib/mysql"
      ];
      environmentFiles = [
        config.age.secrets.projectsend.path
      ];
      extraOptions = [
        "--network=projectsend"
      ];
    };
  };

  # Network for ProjectSend containers
  services.traefik.dynamicConfigOptions.http = {
    routers.projectsend = {
      rule = "Host(`drop.ps7e.xyz`)";
      entryPoints = [
        "websecure"
      ];
      service = "projectsend";
    };
    services.projectsend = {
      loadBalancer.servers = [
        {url = "http://127.0.0.1:9684";}
      ];
    };
  };

  # Persistence configuration for ProjectSend
  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/projectsend";
        user = "sajenim";
        group = "users";
      }
    ];
  };
}
