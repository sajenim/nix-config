{ pkgs, ... }: {
  # Realtime scheduler for low-latency audio
  security.rtkit.enable = true;

  # PipeWire sound server
  services.pipewire = {
    enable = true;

    # Enable ALSA, PulseAudio compatibility, and WirePlumber session manager
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Audio control utilities
  environment.systemPackages = with pkgs; [
    pulsemixer
  ];
}
