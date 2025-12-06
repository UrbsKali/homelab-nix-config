{
  description = "Homelab NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      erotips = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/erotips
          sops-nix.nixosModules.sops
        ];
      };
      creamychocolat = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/creamychocolat
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
