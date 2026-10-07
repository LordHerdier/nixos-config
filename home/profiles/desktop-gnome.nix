# home/profiles/desktop-gnome.nix

{ pkgs, ... }:

{
  imports = [
    ../modules/desktop-packages.nix
    ../modules/kitty.nix
    ../modules/steam.nix
    ../modules/games.nix
    ../modules/gnome-extensions
  ];

  # font-rendering.nix isn't needed here: it exists to hand GTK/Qt apps
  # antialiasing/hinting settings via GSettings/XSettings because
  # Hyprland has no session daemon to push them. GNOME's own
  # gnome-settings-daemon already does this.

  my.kitty.enable = true;

  # GNOME Tweaks exposes the dconf keys Settings doesn't: the GTK/icon
  # theme pickers, fonts and hinting, titlebar buttons, and the Startup
  # Applications list. It's GNOME-session-specific, so it lives here
  # rather than in the shared desktop-packages.nix that the Hyprland
  # profile also imports.
  #
  # Caveat worth knowing before reaching for it: Tweaks is just a dconf
  # editor with a nice face, so any key Home Manager already manages
  # will be written back over on the next activation. On Apthos that
  # includes gtk-theme, color-scheme, accent-color, font-name and
  # button-layout, all set by oneshot-gtk.nix -- change those in Nix,
  # and use Tweaks for the rest.
  home.packages = [ pkgs.gnome-tweaks ];

  # Each extension's packaging and dconf settings live in its own file
  # under ../modules/gnome-extensions.
  my.gnome-extensions = {
    dash-to-dock.enable = true;
    just-perfection.enable = true;
  };
}
