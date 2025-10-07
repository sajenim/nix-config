{inputs, ...}: {
  # Trust viridian's host keys for SSH connections (system-level, uses FQDN)
  programs.ssh.knownHosts = {
    "viridian-ed25519" = {
      hostNames = ["viridian.home.arpa"];
      publicKeyFile = "${inputs.self}/nixos/viridian/ssh_host_ed25519_key.pub";
    };
    "viridian-rsa" = {
      hostNames = ["viridian.home.arpa"];
      publicKeyFile = "${inputs.self}/nixos/viridian/ssh_host_rsa_key.pub";
    };
  };

  # Trust BorgBase repository (offsite backup target)
  programs.ssh.knownHostsFiles = [
    ./borgbase_hosts
  ];
}
