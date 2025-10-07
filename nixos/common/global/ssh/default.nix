{inputs, ...}: {
  # SSH server configuration
  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";           # Disable root login for security
      PasswordAuthentication = false;   # Require key-based authentication
      LogLevel = "VERBOSE";             # Enhanced logging for security auditing
    };

    ports = [22];                       # Standard SSH port
    openFirewall = true;                # Allow SSH through firewall
  };

  # Trusted host keys for internal infrastructure
  programs.ssh.knownHosts = {
    # Desktop workstation (fuchsia)
    "fuchsia-ed25519" = {
      hostNames = ["fuchsia"];
      publicKeyFile = "${inputs.self}/nixos/fuchsia/ssh_host_ed25519_key.pub";
    };
    "fuchsia-rsa" = {
      hostNames = ["fuchsia"];
      publicKeyFile = "${inputs.self}/nixos/fuchsia/ssh_host_rsa_key.pub";
    };

    # Server (viridian)
    "viridian-ed25519" = {
      hostNames = ["viridian"];
      publicKeyFile = "${inputs.self}/nixos/viridian/ssh_host_ed25519_key.pub";
    };
    "viridian-rsa" = {
      hostNames = ["viridian"];
      publicKeyFile = "${inputs.self}/nixos/viridian/ssh_host_rsa_key.pub";
    };
  };

  # External backup provider (BorgBase)
  programs.ssh.knownHostsFiles = [
    ./borgbase_hosts
  ];
}
