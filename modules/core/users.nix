{ config, pkgs, lib, ... }:

{
  # Users
  users.mutableUsers = false;
  users.users.urbai = {
    isNormalUser = true;
    description = "This PC is sooo freakin used";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    hashedPasswordFile = config.sops.secrets."user_passwords/urbai".path;
    openssh.authorizedKeys.keyFiles = [
      config.sops.secrets."ssh_keys/0".path
    ];
    shell = pkgs.zsh;
  };

  sops.secrets."ssh_keys/0" = {
    neededForUsers = true;
  };
}
