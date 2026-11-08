{ inputs, ... }:
let
  inherit (inputs)
    dotfiles
    home-manager
    nixos-hardware
    nixos-wsl
    nixpkgs
    qylock
    ;

  system = "x86_64-linux";

  mkHost =
    {
      hostName,
      isWsl ? false,
      hostPath,
      extraModules ? [ ],
      # Extra Home Manager users beyond charlotte, as
      # username -> list of HM modules. charlotte is always
      # configured from ./home/charlotte.nix + her per-host file;
      # anyone here is configured purely from what's listed
      # (so a full-stack user lists their per-host file too).
      extraHomeUsers ? { },
      # false for headless servers: no home-manager at all, so neither
      # charlotte's per-host home file nor extraHomeUsers is read.
      withHome ? true,
    }:
    nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.hostPlatform = system;
          nixpkgs.overlays = [ (import ./overlay.nix inputs) ];
        }
        # Common system bits
        ../modules/common/packages.nix
        ../modules/common/security.nix
        ../modules/common/time.nix
        ../modules/common/users.nix
        ../modules/common/nix.nix
        ../modules/common/nh.nix

        # Host-specific bits
        hostPath
      ]
      ++ nixpkgs.lib.optionals withHome [
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

          home-manager.users = {
            charlotte = {
              imports = [
                ../home/charlotte.nix
                (../home/hosts + "/${hostName}.nix")
              ];
            };
          }
          // nixpkgs.lib.mapAttrs (_: modules: { imports = modules; }) extraHomeUsers;
        }
      ]
      ++ nixpkgs.lib.optionals isWsl [
        nixos-wsl.nixosModules.wsl
        ../modules/profiles/wsl.nix
      ]
      ++ extraModules;

      specialArgs = { inherit hostName isWsl; };
    };
in
{
  flake.nixosConfigurations = {
    "Charlie-Laptop" = mkHost {
      hostName = "Charlie-Laptop";
      isWsl = true;
      hostPath = ../hosts/Charlie-Laptop/default.nix;
    };

    "Nico" = mkHost {
      hostName = "Nico";
      isWsl = true;
      hostPath = ../hosts/Nico/default.nix;
    };

    "Pine" = mkHost {
      hostName = "Pine";
      isWsl = false;
      hostPath = ../hosts/Pine/default.nix;
    };

    "Work-Laptop" = mkHost {
      hostName = "Work-Laptop";
      isWsl = false;
      hostPath = ../hosts/Work-Laptop/default.nix;
    };

    "Apthos" = mkHost {
      hostName = "Apthos";
      isWsl = false;
      hostPath = ../hosts/Apthos/default.nix;
    };

    "Index" = mkHost {
      hostName = "Index";
      isWsl = false;
      hostPath = ../hosts/Index/default.nix;
      extraModules = [
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        qylock.nixosModules.default
        ../modules/features/qylock.nix
        ../modules/features/dwl
      ];
      extraHomeUsers = {
        kiddo = [ ../home/kiddo.nix ];
        rivian = [
          ../home/rivian.nix
          ../home/hosts/Index.nix
        ];
      };
    };

    # Headless build server (LXC on twm) -- see hosts/Builder.
    "Builder" = mkHost {
      hostName = "Builder";
      hostPath = ../hosts/Builder/default.nix;
      withHome = false;
    };
  };
}
