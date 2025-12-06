{ config, pkgs, lib, ... }:

{
  # Networking
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall = {
    enable = true;
    # Open SSH port by default. Add 80/443 if you host web services.
    allowedTCPPorts = [ 22 ]; 
  };
}
