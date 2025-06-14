{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  modpack = pkgs.fetchPackwizModpack rec {
    version = "9083262";
    url = "https://raw.githubusercontent.com/sajenim/minecraft-modpack/${version}/pack.toml";
    packHash = "sha256-JQTU2qQfiqrAnvp2D0bNwfqYkGyH7yy0cMrNgoCTJ2I=";
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
in {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  services.minecraft-servers = {
    # Enable all of our servers
    enable = true;

    # Our minecraft servers
    servers = {
      kanto = {
        enable = true;
        # The minecraft server package to use.
        package = pkgs.fabricServers.${serverVersion}.override {loaderVersion = fabricVersion;}; # Specific fabric loader version.

        # Allowed players
        whitelist = {
          jasmariiie = "82fc15bb-6839-4430-b5e9-39c5294ff32f";
          Spectre_HWS = "491c085e-f0dc-44f1-9fdc-07c7cfcec8f2";
        };

        # JVM options for the minecraft server.
        jvmOpts = "-Xmx8G";

        # Minecraft server properties for the server.properties file.
        serverProperties = {
          gamemode = "survival";
          difficulty = "normal";
          motd = "\\u00A7aKanto Network \\u00A7e[1.20.1]\\u00A7r\\n\\u00A78I'll Use My Trusty Frying Pan As A Drying Pan!";
          server-port = 25565;
          white-list = true;
          spawn-protection = 0;
          allow-cheats = true;
        };

        # Things to symlink into this server's data directory.
        symlinks = {
          "mods" = "${modpack}/mods";
        };

        # Things to copy into this server's data directory.
        files = {
          "ops.json" = ./ops.json;

          # Your'r in grave danger!
          "config/yigd.json" = "${modpack}/config/yigd.json";
        };

        # Value of systemd's `Restart=` service configuration option.
        restart = "no";
      };
    };

    # Each server will be under a subdirectory named after the server name.
    dataDir = "/var/lib/minecraft";

    # Open firewall for all servers.
    openFirewall = true;
    
    # Enable systemd socket activation. 
    managementSystem.systemd-socket.enable = true;

    # Accept the minecraft EULA.
    eula = true;
    # https://account.mojang.com/documents/minecraft_eula
  };

  # Enable the Traefik reverse proxy.
  services.traefik.dynamicConfigOptions.http = { 
    # Enable the Traefik HTTP router for the minecraft server.
    routers = {
      minecraft = {
        rule = "Host(`mc.home.arpa`)";
        entryPoints = [
          "websecure"
        ];
        service = "minecraft";
      };
    };

    # Define the service for the minecraft server.
    services = {
      minecraft.loadBalancer.servers = [
        {url = "http://127.0.0.1:${toString config.services.minecraft-servers.servers.kanto.serverProperties.server-port}";}
      ];
    };
  };

  # Enable persistence for the data directory.
  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/minecraft";
        user = "minecraft";
        group = "minecraft";
      }
    ];
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "minecraft-server"
  ];
}
