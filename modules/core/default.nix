{ config, pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ./locale.nix
    ./networking.nix
    ./security.nix
    ./users.nix
    ./packages.nix
    ./system.nix
    ./shell.nix
  ];
}
