{
  description = "Nix configs for Charlotte's machines (WSL + NixOS)";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles.url = "github:LordHerdier/Dotfiles";
    dotfiles.flake = false;

    qylock.url = "github:Darkkal44/qylock";

    noctalia.url = "github:noctalia-dev/noctalia/legacy-v4";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    forgejo-cli.url = "git+https://codeberg.org/forgejo-contrib/forgejo-cli";
    forgejo-cli.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      nixos-wsl,
      nixos-hardware,
      nvf,
      dotfiles,
      qylock,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems used by perSystem (even if you don't use much yet)
      systems = [ "x86_64-linux" ];

      # Optional but nice: expose imports later as you grow
      imports = [ ];

      # perSystem is where devShells/packages/checks/formatter can go later
      perSystem =
        {
          pkgs,
          system,
          ...
        }:
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
              extraModules ? [ ],
            }:
            nixpkgs.lib.nixosSystem {
              modules = [
                {
                  nixpkgs.hostPlatform = system;
                  nixpkgs.overlays = [
                    (final: _: {
                      concord = final.callPackage ./pkgs/concord.nix { };
                    })
                  ];
                }
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
                    inherit
                      dotfiles
                      hostName
                      isWsl
                      inputs
                      ;
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
              ]
              ++ extraModules;

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

            "Apthos" = mkHost {
              hostName = "Apthos";
              isWsl = false;
              hostPath = ./hosts/Apthos/default.nix;
            };

            "Index" = mkHost {
              hostName = "Index";
              isWsl = false;
              hostPath = ./hosts/Index/default.nix;
              extraModules = [
                nixos-hardware.nixosModules.framework-amd-ai-300-series
                qylock.nixosModules.default
                ./modules/features/qylock.nix

              ];
            };
          };
        };
    };
}
