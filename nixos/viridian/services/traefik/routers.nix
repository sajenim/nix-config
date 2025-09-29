{...}: {
  services.traefik.dynamicConfigOptions.http.routers = {
    traefik-dashboard = {
      rule = "Host(`traefik.home.arpa`)";
      entryPoints = [
        "websecure"
      ];
      service = "api@internal";
    };
  };
}
