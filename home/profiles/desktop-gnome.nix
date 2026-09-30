# home/profiles/desktop-gnome.nix

{ pkgs, ... }:

{
  imports = [
    ../modules/desktop-packages.nix
    ../modules/kitty.nix
    ../modules/steam.nix
    ../modules/games.nix
  ];

  # font-rendering.nix isn't needed here: it exists to hand GTK/Qt apps
  # antialiasing/hinting settings via GSettings/XSettings because
  # Hyprland has no session daemon to push them. GNOME's own
  # gnome-settings-daemon already does this.

  my.kitty.enable = true;

  # Vanilla GNOME only shows the dash inside the Activities overview.
  # dash-to-dock pins it to the desktop as a persistent taskbar/dock.
  home.packages = [ pkgs.gnomeExtensions.dash-to-dock ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-fixed = true;
      dock-position = "BOTTOM";
      extend-height = false;
      autohide = false;
      intellihide = true;
    };
  };
}
