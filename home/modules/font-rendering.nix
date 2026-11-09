# home/modules/font-rendering.nix
#
# Hyprland has no session daemon (gnome-settings-daemon) to push
# antialiasing/hinting settings to GTK/Qt apps via GSettings/XSettings,
# so without this, GTK3/GTK4/Qt apps fall back to poor-looking defaults
# even though fontconfig itself is configured correctly.

{ pkgs, ... }:

{
  gtk = {
    enable = true;

    font = {
      name = "Noto Sans";
      size = 10;
    };

    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };

    gtk4.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
  };

  # Make Qt apps follow the GTK theme/fonts instead of rendering with
  # their own (often unhinted) defaults.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];
}
