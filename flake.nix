{
  description = "Nix configs for Charlotte's machines (WSL + NixOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles.url = "github:LordHerdier/Dotfiles";
    dotfiles.flake = false;

    self.submodules = true;
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      nixos-wsl,
      dotfiles,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems used by perSystem (even if you don't use much yet)
      systems = [ "x86_64-linux" ];

      # Optional but nice: expose imports later as you grow
      imports = [ ];

      # perSystem is where devShells/packages/checks/formatter can go later
      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style or pkgs.nixfmt;
        };

      flake =
        let
          system = "x86_64-linux";

          mkHost =
            {
              hostName,
              isWsl ? false,
              hostPath,
            }:
            nixpkgs.lib.nixosSystem {
              inherit system;

              modules = [
                (
                  { ... }:
                  {
                    nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];
                  }
                )

                # Common system bits
                ./modules/common/packages.nix
                ./modules/common/security.nix
                ./modules/common/time.nix
                ./modules/common/users.nix
                ./modules/common/nix.nix

                # Host-specific bits
                hostPath

                # Home Manager
                home-manager.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;

                  home-manager.extraSpecialArgs = {
                    inherit dotfiles hostName isWsl;
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
            };
          };
        };
    };
}
