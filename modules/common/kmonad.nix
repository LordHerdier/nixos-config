# modules/common/kmonad.nix

{ Dotfiles, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kmonad ];

  services.kmonad = {
    enable = true;
    extraArgs = "${Dotfiles}/kmonad/.config/kmonad/colemakHomerowMods.kbd";
  };
  
}

