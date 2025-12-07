{ pkgs, modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 2147483648; # 2048MB

  environment.systemPackages = with pkgs; [
    git
    parted
    e2fsprogs
  ];

  # Embed the sops key from the build machine
  # NOTE: This requires building with --impure
  environment.etc."sops-nix/key.txt".source = /var/lib/sops-nix/key.txt;

  services.getty.autologinUser = "root";

  systemd.services.auto-install = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "auto-install" ''
        set -euo pipefail
        echo "Waiting for network..."
        # Wait for internet connection (simple check)
        until ${pkgs.curl}/bin/curl -s --head http://google.com; do
          sleep 1
        done

        echo "Partitioning /dev/sda..."
        # WARNING: This wipes /dev/sda
        ${pkgs.parted}/bin/parted /dev/sda -- mklabel msdos
        ${pkgs.parted}/bin/parted /dev/sda -- mkpart primary ext4 1MiB 100%
        ${pkgs.parted}/bin/parted /dev/sda -- set 1 boot on
        
        # Wait for kernel to register partitions
        sleep 2

        echo "Formatting..."
        ${pkgs.e2fsprogs}/bin/mkfs.ext4 -L nixos-root -F /dev/sda1

        echo "Mounting..."
        mount /dev/disk/by-label/nixos-root /mnt

        echo "Starting installation..."
        
        # Copy the embedded sops key to the target system
        mkdir -p /mnt/var/lib/sops-nix
        cp /etc/sops-nix/key.txt /mnt/var/lib/sops-nix/key.txt
        chmod 600 /mnt/var/lib/sops-nix/key.txt

        ${pkgs.nixos-install}/bin/nixos-install \
          --no-root-passwd \
          --flake github:UrbsKali/homelab-nix-config#creamychocolat
        
        echo "Installation complete! Rebooting in 2 seconds..."
        sleep 2
        reboot
      '';
    };
  };
}
