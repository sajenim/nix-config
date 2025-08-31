{ pkgs, ... }: {
  # Realtime scheduler
  security.rtkit.enable = true;

  # Sound server
  services.pipewire = {
    enable = true;

    # Enable components
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Sound mixer
  environment.systemPackages = with pkgs; [
    pulsemixer
  ];
}
