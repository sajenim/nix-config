{...}: {
  # Global SSH server configuration baseline
  # Host-specific trust relationships are configured in each host's services/ssh/

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "prohibit-password";  # Allow root login with keys only
      PasswordAuthentication = false;         # Require key-based authentication
      LogLevel = "VERBOSE";                   # Enhanced logging for security auditing
    };

    ports = [22];                             # Standard SSH port
    openFirewall = true;                      # Allow SSH through firewall
  };
}
