# home/modules/oneshot-gtk.nix
#
# The OneShot World Machine GTK theme (pkgs/oneshot-gtk-theme), wired up
# for a GNOME session. Sibling of oneshot-cursors.nix, and like that one
# it drives GNOME through dconf rather than Home Manager's `gtk` module:
# gnome-settings-daemon pushes the dconf values at GTK and XWayland apps
# and overrides anything written to gtk-3.0/settings.ini, so settings.ini
# is simply the losing side of that race under GNOME. (The `gtk` module is
# also off for this user on GNOME hosts -- font-rendering.nix, which turns
# it on, is only imported by the Hyprland profile.)
#
# Three separate things have to happen for the theme to actually land:
#
#   1. The package goes in home.packages so the theme directory shows up
#      under ~/.nix-profile/share/themes, which is on XDG_DATA_DIRS and so
#      is where GTK looks for a theme by name.
#   2. dconf gtk-theme = "Oneshot" selects it. This covers GTK2 and GTK3
#      apps.
#   3. The GTK4 stylesheet is copied to ~/.config/gtk-4.0/ separately,
#      because step 2 does NOT reach libadwaita apps -- see below.

{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  theme = "${pkgs.oneshot-gtk-theme}/share/themes/Oneshot";
  cfg = config.my.oneshot-gtk;
in
{
  options.my.oneshot-gtk = {
    pixelFont = mkEnableOption ''
      replacing the interface font with Terminus 10, the bitmap font the
      game's own UI uses. Off by default: it's a drastic, deliberately
      un-antialiased look, and it applies to every GTK app, not just the
      ones that suit it
    '';
  };

  config = mkMerge [
    {
      home.packages = [ pkgs.oneshot-gtk-theme ];

      dconf.settings."org/gnome/desktop/interface" = {
        gtk-theme = "Oneshot";

        # The theme is black-on-black with a light foreground, so GTK apps
        # need to be in dark mode or they'll render light text on light
        # chrome in the places the stylesheet doesn't reach.
        color-scheme = "prefer-dark";

        # GNOME 47+ accent color. It's an 8-value enum, not free-form hex,
        # so this can't be the game's exact #9664ff -- it only steers the
        # bits of GNOME Shell the GTK stylesheet can't touch (the overview,
        # the top bar, switches in Settings). "purple" is the nearest.
        accent-color = "purple";
      };

      # Square titlebar buttons, minimize/maximize/close only, matching the
      # xfwm4 button_layout the upstream rice uses ("|HMC").
      dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";

      # --- The GTK4 / libadwaita half ------------------------------------
      #
      # libadwaita apps (Nautilus, Settings, Text Editor, ...) ignore
      # gtk-theme-name outright: adw_init() installs Adwaita's own
      # stylesheet and never consults the theme directory, so step 2 above
      # has no effect on them. The only provider that outranks libadwaita's
      # sheet is the *user* stylesheet at ~/.config/gtk-4.0/gtk.css
      # (GTK_STYLE_PROVIDER_PRIORITY_USER = 800 vs. THEME = 200), which is
      # what these two lines install.
      #
      # assets/ has to come along as its own entry because the stylesheet
      # references it relatively -- url("assets/diamond.png") resolves
      # against the CSS file's own location, which is ~/.config/gtk-4.0
      # here, not the store path.
      #
      # If the `gtk` module is ever enabled for this user, gtk.gtk4.extraCss
      # writes this same path and the two will collide; move this over to
      # that option rather than having both.
      xdg.configFile."gtk-4.0/gtk.css".source = "${theme}/gtk-4.0/gtk.css";
      xdg.configFile."gtk-4.0/assets".source = "${theme}/gtk-4.0/assets";
    }

    (mkIf cfg.pixelFont {
      # The fontconfig family really is "Terminus (TTF)", not "Terminus" --
      # that's what terminus_font_ttf registers as (check with fc-list).
      # A wrong family name here silently falls back to the default sans
      # rather than erroring, so it's easy to think the font "didn't work"
      # when the name was just wrong.
      home.packages = [ pkgs.terminus_font_ttf ];
      dconf.settings."org/gnome/desktop/interface".font-name = "Terminus (TTF) 10";
    })
  ];
}
