# home/modules/oneshot-cursors.nix
#
# The OneShot World Machine cursor theme (pkgs/oneshot-cursors), wired up
# for a GNOME session. The Hyprland side sets its own cursor in
# hyprland/40-design.nix, so don't import both into one host -- they both
# define home.pointerCursor and would collide.

{ pkgs, ... }:

let
  cursorSize = 24;
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.oneshot-cursors;
    name = "Oneshot-Cursors";
    size = cursorSize;
  };

  # home.pointerCursor alone only drops the theme into ~/.icons and exports
  # XCURSOR_THEME/XCURSOR_SIZE. GNOME ignores both: mutter draws the
  # Wayland cursor from the dconf value below, and gnome-settings-daemon
  # pushes that same value at GTK and XWayland apps, overriding the
  # environment. So the theme is only actually visible once it's set here
  # too. (gtk.enable isn't used instead because the gtk module isn't on
  # for this user, and under GNOME gsd would win over its settings.ini
  # anyway.)
  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = "Oneshot-Cursors";
    cursor-size = cursorSize;
  };
}
