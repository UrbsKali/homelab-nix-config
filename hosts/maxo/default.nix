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

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "server description" = "Homelab NAS";
        workgroup = "WORKGROUP";
        "security" = "user";
      };
      nas = {
        path = "/tank/nas";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "urbai";
        "force user" = "urbai";
        "force group" = "users";
        "create mask" = "0660";
        "directory mask" = "0770";
        "force create mode" = "0660";
        "force directory mode" = "0770";
      };
      media = {
        path = "/data/media";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "urbai";
      };
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /tank/nas 10.0.0.0/24(rw,sync,no_subtree_check)
      /data/media 10.0.0.0/24(ro,sync,no_subtree_check)
    '';
  };

  fileSystems = {
    "/tank/ente" = { device = "tank/ente"; fsType = "zfs"; options = [ "zfsutil" ]; };
    "/tank/nas" = { device = "tank/nas"; fsType = "zfs"; options = [ "zfsutil" ]; };
    "/tank/backups" = { device = "tank/backups"; fsType = "zfs"; options = [ "zfsutil" ]; };
    "/data/media" = { device = "data/media"; fsType = "zfs"; options = [ "zfsutil" ]; };
    "/data/docker" = { device = "data/docker"; fsType = "zfs"; options = [ "zfsutil" ]; };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 2049 ];
  networking.firewall.allowedUDPPorts = [ 2049 ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Else the RustFS S3 is failing to boot because the ZFS pools are not mounted yet.
  systemd.services.docker = {
    after = [ "zfs-mount.service" ];
    requires = [ "zfs-mount.service" ];
  };
}