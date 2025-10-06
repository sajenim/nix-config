{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Our ephemeral system. Wipe root on reboot.
    ../common/optional/ephemeral-btrfs.nix
  ];

  # Boot configuration
  boot = {
    # Initial ramdisk
    initrd = {
      # The modules listed here are available in the initrd, but are only loaded on demand.
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
      # List of modules that are always loaded by the initrd.
      kernelModules = ["kvm-intel"];
    };

    # Runtime parameters of the Linux kernel
    kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 0;
    };

    # Our boot loader configuration
    loader = {
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
      systemd-boot.enable = true;
    };
  };

  # Hardware configuration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };

  # Setup our filesystems
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 16 * 1024;
    }
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
