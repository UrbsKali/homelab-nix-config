{ config, pkgs, lib, ... }:

{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Optimize storage (deduplicate files)
  nix.settings.auto-optimise-store = true;
}
