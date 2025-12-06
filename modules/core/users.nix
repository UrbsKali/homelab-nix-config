{ config, pkgs, lib, ... }:

{
  # Users
  users.mutableUsers = false;
  users.users.urbai = {
    isNormalUser = true;
    description = "This PC is sooo freakin used";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    hashedPassword = config.sops.secrets."user_passwords/urbai";
    openssh.authorizedKeys.keys = [
      config.sops.secrets."ssh_keys/0"
    ];
    shell = pkgs.zsh;
  };

  sops.secrets."ssh_keys/0" = {
    neededForUsers = true;
  };
}
