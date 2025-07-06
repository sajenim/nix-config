{...}: {
  # Enable CUPS for printing services.
  services.printing = {
    enable = true;
    # Connect to a remote CUPS server. 
    clientConf = ''
      ServerName 192.168.50.249
      ServerPort 631
    '';
  };
}
