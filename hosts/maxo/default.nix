{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/services/docker.nix
    ../../modules/services/tunnel.nix
  ];

  networking.hostName = "maxo";
  networking.hostId = "4d61786f";

  # This host uses a fixed address on the homelab LAN.
  networking.networkmanager.enable = lib.mkForce false;
  networking.useDHCP = lib.mkForce false;
  networking.interfaces.eno2.ipv4.addresses = [{
    address = "10.0.0.36";
    prefixLength = 24;
  }];
  networking.defaultGateway = "10.0.0.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  services.tunnel.enable = true;

  virtualisation.docker.daemon.settings.data-root = lib.mkForce "/data/docker";

  boot.zfs = {
    extraPools = [ "tank" "data" ];
    forceImportRoot = false;
  };
  services.zfs.autoScrub = {
    enable = true;
    pools = [ "tank" "data" ];
  };

  fileSystems = {
    "/tank/ente" = { device = "tank/ente"; fsType = "zfs"; };
    "/tank/nas" = { device = "tank/nas"; fsType = "zfs"; };
    "/tank/backups" = { device = "tank/backups"; fsType = "zfs"; };
    "/data/media" = { device = "data/media"; fsType = "zfs"; };
    "/data/docker" = { device = "data/docker"; fsType = "zfs"; };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}