# home/profiles/desktop-gnome.nix

{ pkgs, ... }:

{
  imports = [
    ../modules/desktop-packages.nix
    ../modules/kitty.nix
    ../modules/spicetify.nix
    ../modules/steam.nix
    ../modules/games.nix
    ../modules/gnome-extensions
  ];

  # No font-rendering.nix: gnome-settings-daemon already pushes
  # antialiasing/hinting to GTK/Qt apps.

  my.kitty.enable = true;
  my.spicetify.enable = true;

  # GNOME Tweaks, for the dconf keys Settings doesn't expose. Keys Home
  # Manager manages are overwritten on the next activation -- on Apthos
  # gtk-theme, color-scheme, accent-color, font-name and button-layout
  # (oneshot-gtk.nix); change those in Nix.
  home.packages = [ pkgs.gnome-tweaks ];

  # One file per extension under ../modules/gnome-extensions.
  my.gnome-extensions = {
    dash-to-dock.enable = true;
    just-perfection.enable = true;
  };
}
