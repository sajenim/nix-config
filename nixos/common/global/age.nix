# Agenix secret management with YubiKey rekeying
# Handles encrypted secrets for services requiring credentials
{
  config,
  pkgs,
  inputs,
  ...
}: let
  hostname = config.networking.hostName;
in {
  # Module imports
  imports = [
    ./secrets.nix
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  # Overlay provides agenix-rekey package and extensions
  nixpkgs.overlays = [
    inputs.agenix-rekey.overlays.default
  ];

  # CLI tool for manual secret rekeying operations
  environment.systemPackages = with pkgs; [
    agenix-rekey
  ];

  # Secret decryption configuration
  # Use persistent paths to ensure SSH keys are available during early boot
  # activation, before impermanence bind mounts /etc/ssh/
  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_rsa_key"
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ];

  # YubiKey-based secret rekeying
  age.rekey = {
    hostPubkey = ../../${hostname}/ssh_host_ed25519_key.pub;
    masterIdentities = [
      ../users/sajenim/agenix-rekey.pub
    ];
    storageMode = "local";
    localStorageDir = ./. + "/secrets/rekeyed/${hostname}";
  };
}
