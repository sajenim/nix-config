{
  config,
  lib,
  pkgs,
  ...
}: {
  # Internet connection sharing for 3D printer over Ethernet
  # Shares WiFi connection (wlo1) to Ethernet (enp34s0) using 10.1.0.0/24

  # Enable IP forwarding to route traffic between interfaces
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking = {
    # Tell NetworkManager not to manage the Ethernet interface
    networkmanager.unmanaged = ["enp34s0"];

    # Configure static IP on Ethernet interface
    interfaces.enp34s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.1.0.1";
          prefixLength = 24;
        }
      ];
    };

    # Firewall configuration for connection sharing
    firewall = {
      # Allow DHCP and DNS traffic on the Ethernet interface
      interfaces.enp34s0 = {
        allowedUDPPorts = [
          53  # DNS queries
          67  # DHCP server
        ];
      };

      # Allow traffic forwarding
      extraCommands = ''
        # NAT: masquerade traffic from Ethernet going to WiFi
        iptables -t nat -A POSTROUTING -o wlo1 -j MASQUERADE

        # Allow forwarding from Ethernet to WiFi (printer -> internet)
        iptables -A FORWARD -i enp34s0 -o wlo1 -j ACCEPT

        # Allow forwarding from WiFi to Ethernet (phone -> printer)
        # This enables devices on 192.168.50.x to access the printer
        iptables -A FORWARD -i wlo1 -o enp34s0 -j ACCEPT
      '';
    };
  };

  # DHCP server for automatic IP assignment to printer
  services.dnsmasq = {
    enable = true;
    settings = {
      # Only listen on the Ethernet interface
      interface = "enp34s0";
      # Bind only to specified interface
      bind-interfaces = true;
      # Don't read /etc/resolv.conf
      no-resolv = true;
      # DHCP range: 10.1.0.2 through 10.1.0.10, 24h lease
      dhcp-range = ["10.1.0.2,10.1.0.10,24h"];
      # Upstream DNS: Pi-hole for ad-blocking and network-wide filtering
      server = ["192.168.50.249"];
      # Gateway for DHCP clients
      dhcp-option = ["option:router,10.1.0.1"];
      # Static DHCP reservation for 3D printer (BigTreeTech CB1)
      dhcp-host = [
        "5a:0a:da:dc:b8:2f,10.1.0.2,bigtreetech-cb1,infinite"
      ];
    };
  };
}
