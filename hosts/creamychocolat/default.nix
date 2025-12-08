{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/services/docker.nix
  ];

  networking.hostName = "creamychocolat";

  networking.interfaces.enp0s3.ipv4.addresses = [{
    address = "192.168.1.35";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
