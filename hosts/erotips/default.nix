{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/services/docker.nix
    ../../modules/services/tunnel.nix
  ];

  networking.hostName = "erotips";

  # This host uses static interface config, so do not generate NM-managed networking.
  networking.networkmanager.enable = lib.mkForce false;
  networking.useDHCP = lib.mkForce false;

  services.tunnel.enable = true;

  # Enable Intel VA-API on Sandy Bridge (i7-2600) for container passthrough via /dev/dri.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libvdpau-va-gl
      vaapiVdpau
      intel-media-driver
    ];
  };

  # i7-2600 uses the legacy i965 VA-API path.
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";

  # Allow the interactive user to access GPU device nodes for validation tools.
  users.users.urbai.extraGroups = [ "video" "render" ];

  networking.interfaces.enp6s0.ipv4.addresses = [{
    address = "192.168.1.44";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Open ports for media services (Jellyseerr, Jellyfin, Radarr, Sonarr, Qbittorrent, Prowlarr)
  networking.firewall.allowedTCPPorts = [ 5055 8096 7878 8989 5080 9696 ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdc"; # Updated to sdc based on lsblk
  boot.loader.grub.useOSProber = true;

  # LVM Mount for Docker Volume
  fileSystems."/home/dvb/docker/volumes/media-stack_torrent-downloads/_data" = {
    device = "/dev/media-vol/media-lv";
    fsType = "ext4";
  };
}
