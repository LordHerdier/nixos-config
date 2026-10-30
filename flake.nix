{
  description = "Nix configs for Charlotte's machines (WSL + NixOS)";

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

    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    easyeffects-presets.url = "github:Soab42/easyeffects-presets";
    easyeffects-presets.flake = false;

    hacky-tts.url = "git+https://git.lorscapa.com/LordHerdier/hacky-tts.git";
    hacky-tts.inputs.nixpkgs.follows = "nixpkgs";

    hacky-launcher.url = "git+https://git.lorscapa.com/LordHerdier/hacky-launcher.git";
    hacky-launcher.inputs.nixpkgs.follows = "nixpkgs";
    forgejo-cli.url = "git+https://codeberg.org/forgejo-contrib/forgejo-cli";
    forgejo-cli.inputs.nixpkgs.follows = "nixpkgs";

    hyprCRT-shader.url = "github:LordHerdier/hyprCRT-shader";
    hyprCRT-shader.inputs.nixpkgs.follows = "nixpkgs";

    # Upstream, not the pfaj fork: the fork lags on profile options
    # (extensionButtons and newer) that home/modules/zen-browser uses.
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # Upstream asks for nixpkgs-unstable here, to stay in step with the
    # Firefox version the Zen artifacts are built against.
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    concord.url = "github:chojs23/concord";
    concord.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./parts/dev.nix
        ./parts/hosts.nix
      ];
    };
}
