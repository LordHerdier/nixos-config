# home/modules/kmonad.nix

{ Dotfiles, pkgs, ... }:

{
  home.packages = [ pkgs.kmonad ];

  systemd.user.services.kmonad = {
    Unit = {
      Description = "KMonad keyboard remapping";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.kmonad}/bin/kmonad ${Dotfiles}/kmonad/.config/kmonad/colemakHomerowMods.kbd";
      Restart = "always";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

