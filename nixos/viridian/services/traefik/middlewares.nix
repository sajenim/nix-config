{...}: {
  # Attached to the routers, pieces of middleware are a means of tweaking the requests before they are sent to your service
  services.traefik.dynamicConfigOptions.http.middlewares = {
    # Intrusion Prevention System
    crowdsec.plugin.bouncer = {
      enabled = "true";
      defaultDecisionSeconds = "60";
      crowdsecMode = "live";
      crowdsecAppsecEnabled = "true";
      crowdsecAppsecHost = "localhost:7422";
      crowdsecAppsecFailureBlock = "true";
      crowdsecAppsecUnreachableBlock = "true";
      crowdsecLapiKey = "18c725d5-3a22-4331-a8e8-abfd3018a7c0";
      crowdsecLapiHost = "localhost:8080";
      crowdsecLapiScheme = "http";
      crowdsecLapiTLSInsecureVerify = "false";
      forwardedHeadersTrustedIPs = [
        # private class ranges
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
      clientTrustedIPs = [
        # private class ranges
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
    };
  };
}
