{ config, pkgs, lib, ... }:

{
  # Systemd Tweaks
  systemd = {
    enableEmergencyMode = false;
    settings.Manager = {
      RuntimeWatchdogSec = lib.mkDefault "15s";
      RebootWatchdogSec = lib.mkDefault "30s";
      KExecWatchdogSec = lib.mkDefault "1m";
    };
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
  
  boot.initrd.systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
    "emergency.service"
    "emergency.target"
  ];

  system.stateVersion = "24.11";

  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.mail.enable = false; # Set to true if you configure mail
  };
}
