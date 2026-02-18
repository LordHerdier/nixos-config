# home/modules/kmonad.nix

{ Dotfiles, pkgs, ... }:

{
  home.packages = [ pkgs.kmonad ];

  services.kmonad = {
    enable = true;
    extraArgs = "${Dotfiles}/kmonad/.config/kmonad/colemakHomerowMods.kbd";
  };
  
}

