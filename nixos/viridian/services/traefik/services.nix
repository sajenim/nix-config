{...}: {
  services.traefik.dynamicConfigOptions.http.services = {
    open-webui.loadBalancer.servers = [
      {url = "http://fuchsia.home.arpa:8080";}
    ];
  };
}
