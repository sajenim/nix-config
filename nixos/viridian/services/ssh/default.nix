{inputs, ...}: let
  # Fuchsia's host key for backup authentication
  fuchsiaHostKey = builtins.readFile (
    "${inputs.self}/nixos/fuchsia/ssh_host_ed25519_key.pub"
  );
in {
  # Trust fuchsia's host keys for SSH connections (system-level, uses FQDN)
  programs.ssh.knownHosts = {
    "fuchsia-ed25519" = {
      hostNames = ["fuchsia.home.arpa"];
      publicKeyFile = "${inputs.self}/nixos/fuchsia/ssh_host_ed25519_key.pub";
    };
    "fuchsia-rsa" = {
      hostNames = ["fuchsia.home.arpa"];
      publicKeyFile = "${inputs.self}/nixos/fuchsia/ssh_host_rsa_key.pub";
    };
  };

  # Trust BorgBase repository (offsite backup target)
  programs.ssh.knownHostsFiles = [
    ./borgbase_hosts
  ];

  # Accept remote backups from fuchsia using host key authentication
  users.users.root.openssh.authorizedKeys.keys = [
    # Restrict fuchsia to only run borg serve in /srv/borg-repo
    ''command="borg serve --restrict-to-path /srv/borg-repo",restrict ${fuchsiaHostKey}''
  ];
}
