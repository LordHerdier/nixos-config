# home/modules/oneshot-gtk.nix
#
# The OneShot World Machine theme (pkgs/oneshot-gtk-theme), wired up for
# a GNOME session. Sibling of oneshot-cursors.nix, and like that one it
# drives GNOME through dconf rather than Home Manager's `gtk` module:
# gnome-settings-daemon pushes the dconf values at GTK and XWayland apps
# and overrides anything written to gtk-3.0/settings.ini, so settings.ini
# is simply the losing side of that race under GNOME. (The `gtk` module is
# also off for this user on GNOME hosts -- font-rendering.nix, which turns
# it on, is only imported by the Hyprland profile.)
#
# The theme covers three independent surfaces, and none of the three
# installs the others. This module is where all of them get wired up, so
# that one palette choice (`my.oneshot-gtk.palette`) governs the lot:
#
#   1. The package goes in home.packages so the theme directory shows up
#      under ~/.nix-profile/share/themes, which is on XDG_DATA_DIRS and so
#      is where GTK -- and the Shell's User Themes extension -- look for
#      a theme by name.
#   2. dconf gtk-theme = "Oneshot" selects it. This covers GTK2 and GTK3
#      apps.
#   3. The GTK4 stylesheet is copied to ~/.config/gtk-4.0/ separately,
#      because step 2 does NOT reach libadwaita apps -- see below.
#   4. GNOME Shell itself (top bar, overview, panel menus) is styled by
#      neither of those; it needs the User Themes extension and its own
#      `name` key -- also below.

{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.my.oneshot-gtk;

  t = config.my.theme.palettes.${cfg.palette};
  p = t.palette;
  r = t.roles;

  # The stylesheets' colors are arguments now -- see
  # pkgs/oneshot-gtk-theme/default.nix. These six are every distinct
  # color they use.
  themePkg = pkgs.oneshot-gtk-theme.override {
    background = p.bg;
    backgroundHover = r.surfaceAlt;
    accent = r.accent;
    accentDim = r.accentDim;
    accentMuted = r.muted;
    accentStandalone = p.fg;
  };

  theme = "${themePkg}/share/themes/Oneshot";

  # What actually gets installed as the user stylesheet: the theme's GTK4
  # sheet followed by our per-app patches. app-overrides.css explains why
  # those cannot just live in gtk.css -- the short version is that an app
  # redeclaring a libadwaita color property on its own widget tree beats
  # an inherited one no matter which provider set it.
  userGtk4Css = pkgs.concatText "gtk.css" [
    "${theme}/gtk-4.0/gtk.css"
    "${theme}/gtk-4.0/app-overrides.css"
  ];
in
{
  options.my.oneshot-gtk = {
    pixelFont = mkEnableOption ''
      replacing the interface font with Terminus 10, the bitmap font the
      game's own UI uses. Off by default: it's a drastic, deliberately
      un-antialiased look, and it applies to every GTK app, not just the
      ones that suit it
    '';

    palette = mkOption {
      type = types.enum (lib.attrNames config.my.theme.palettes);
      # Pinned to "oneshot" rather than following my.theme.default, and
      # this one is meant to stay pinned: the rice is an art-directed
      # look for one host, and the oneshot palette collapses every ANSI
      # slot onto a single hue, which makes it a fine UI palette and a
      # useless terminal one. Point it at another palette to re-skin the
      # GTK theme without touching the stylesheets.
      default = "oneshot";
      description = "Which my.theme palette the GTK stylesheets are built from.";
    };
  };

  config = mkMerge [
    {
      home.packages = [ themePkg ];

      dconf.settings."org/gnome/desktop/interface" = {
        gtk-theme = "Oneshot";

        # The theme is black-on-black with a light foreground, so GTK apps
        # need to be in dark mode or they'll render light text on light
        # chrome in the places the stylesheet doesn't reach.
        color-scheme = "prefer-dark";

        # GNOME 47+ accent color. It's a nine-value enum, not free-form
        # hex, so it can't be the accent exactly. The helper picks the
        # nearest of the nine to whatever the palette's accent is, which
        # for the oneshot purple lands on "purple", the value this was
        # hardcoded to before.
        #
        # This is a fallback, not the Shell's colour scheme: the enum
        # only reaches a handful of St widgets (switches, focus rings,
        # the workspace indicator) and leaves the overview's own
        # surfaces -- grid backdrop, app tiles, dash -- at GNOME's
        # greys, which is why the accent never read as purple there.
        # The shell theme below is what actually colours those. Keep it
        # set anyway: libadwaita apps read the same key for their own
        # accent, and it still applies in the places the shell theme
        # leaves alone (GDM, for one, which runs its own session).
        accent-color = config.my.theme.lib.nearestGnomeAccent r.accent;
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
      # That priority wins against an app's own stylesheet too, but only
      # on nodes both of them match -- so a handful of libadwaita apps
      # need to be named explicitly. Those rules are the second half of
      # userGtk4Css above; see theme/gtk-4.0/app-overrides.css.
      #
      # assets/ has to come along as its own entry because the stylesheet
      # references it relatively -- url("assets/diamond.png") resolves
      # against the CSS file's own location, which is ~/.config/gtk-4.0
      # here, not the store path.
      #
      # If the `gtk` module is ever enabled for this user, gtk.gtk4.extraCss
      # writes this same path and the two will collide; move this over to
      # that option rather than having both.
      xdg.configFile."gtk-4.0/gtk.css".source = userGtk4Css;
      xdg.configFile."gtk-4.0/assets".source = "${theme}/gtk-4.0/assets";

      # --- The GNOME Shell half ------------------------------------------
      #
      # The top bar, the overview and the panel menus are St widgets, not
      # GTK ones: they're styled by gnome-shell's own stylesheet, which
      # is compiled into the binary as a GResource. gtk-theme doesn't
      # reach them and neither does ~/.config/gtk-4.0. The User Themes
      # extension is the only supported way in -- see its module for how
      # it finds a theme, and theme/gnome-shell/gnome-shell.css in the
      # package for what gets overridden and why it needn't be a
      # complete stylesheet.
      #
      # `name` has to match the directory under share/themes, which is
      # the same "Oneshot" that gtk-theme selects above.
      my.gnome-extensions.user-themes.enable = true;
      dconf.settings."org/gnome/shell/extensions/user-theme".name = "Oneshot";
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
