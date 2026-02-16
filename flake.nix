# flake.nix

{
  description = "Nix configs for Charlotte's machines (WSL + NixOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles.url = "github:LordHerdier/Dotfiles";
    dotfiles.flake = false;

    ambxst.url = "github:Axenide/Ambxst";
    ambxst.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {  nixpkgs, home-manager, nixos-wsl, dotfiles, ... }:
  let
    system = "x86_64-linux";

    mkHost = { hostName, isWsl ? false, hostPath }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            # Common system bits
            ./modules/common/packages.nix
            ./modules/common/security.nix
            ./modules/common/time.nix
            ./modules/common/users.nix
            ./modules/common/nix.nix

            # Host-specific bits
            hostPath
            
            # Make an if to load ambxst or not
            (nixpkgs.lib.mkIf enableAmbxst ambxst.nixosModules.default)

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = {
                inherit dotfiles;
                inherit hostName isWsl;
              };

              home-manager.users.charlotte = {
                imports = [
                  ./home/charlotte.nix
                  (./home/hosts + "/${hostName}.nix")
                ];
              };
            }
          ]
          ++ nixpkgs.lib.optionals isWsl [
            nixos-wsl.nixosModules.wsl
            ./modules/profiles/wsl.nix
          ];

        specialArgs = { inherit hostName isWsl; };
      };
  in
  {
    nixosConfigurations = {
      "Charlie-Laptop" = mkHost {
        hostName = "Charlie-Laptop";
        isWsl = true;
        hostPath = ./hosts/Charlie-Laptop/default.nix;
      };

      "Nico" = mkHost {
        hostName = "Nico";
        isWsl = true;
        hostPath = ./hosts/Nico/default.nix;
      };

      "Pine" = mkHost {
        hostName = "Pine";
        isWsl = false;
        hostPath = ./hosts/Pine/default.nix;
        enableAmbxst = true;
        };
    };
  };
}
