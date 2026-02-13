{
  description = "NixOS-WSL config for Charlie-Laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles.url = "github:LordHerdier/Dotfiles";
    dotfiles.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, dotfiles, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations."Charlie-Laptop" = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        nixos-wsl.nixosModules.wsl
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit dotfiles; };

          home-manager.users.charlotte = import ./home/charlotte.nix;
        }
      ];
    };
  };
}
