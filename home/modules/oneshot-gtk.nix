# home/modules/oneshot-gtk.nix
#
# The OneShot World Machine theme (pkgs/oneshot-gtk-theme) for a GNOME
# session. Driven through dconf rather than Home Manager's `gtk` module:
# gnome-settings-daemon overrides gtk-3.0/settings.ini. (The `gtk` module
# is off on GNOME hosts anyway; only the Hyprland profile's
# font-rendering.nix enables it.)
#
# Four pieces, none of which installs the others, all built from one
# palette (`my.oneshot-gtk.palette`):
#
#   1. home.packages, so share/themes/Oneshot is on XDG_DATA_DIRS for GTK
#      and the User Themes extension.
#   2. dconf gtk-theme = "Oneshot" for GTK2/GTK3 apps.
#   3. The GTK4 user stylesheet for libadwaita apps, which ignore (2).
#   4. GNOME Shell via the User Themes extension.

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

  # Every distinct color the stylesheets use; see
  # pkgs/oneshot-gtk-theme/default.nix.
  themePkg = pkgs.oneshot-gtk-theme.override {
    background = p.bg;
    backgroundHover = r.surfaceAlt;
    accent = r.accent;
    accentDim = r.accentDim;
    accentMuted = r.muted;
    accentStandalone = p.fg;
  };

  theme = "${themePkg}/share/themes/Oneshot";

  # The theme's GTK4 sheet plus per-app patches. app-overrides.css says
  # why they can't live in gtk.css: an app redeclaring a libadwaita color
  # on its own widgets beats an inherited one from any provider.
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
      # Pinned, not my.theme.default: the rice is an art-directed look for
      # one host. Point it elsewhere to re-skin without touching the CSS.
      default = "oneshot";
      description = "Which my.theme palette the GTK stylesheets are built from.";
    };
  };

  config = mkMerge [
    {
      home.packages = [ themePkg ];

      dconf.settings."org/gnome/desktop/interface" = {
        gtk-theme = "Oneshot";

        # Else light text on light chrome where the stylesheet doesn't
        # reach.
        color-scheme = "prefer-dark";

        # Nearest of GNOME's nine accent values ("purple" for oneshot).
        # Only reaches a few St widgets -- the shell theme below colours
        # the rest -- but libadwaita apps and GDM read it too.
        accent-color = config.my.theme.lib.nearestGnomeAccent r.accent;
      };

      # Square titlebar buttons, minimize/maximize/close only, matching the
      # xfwm4 button_layout the upstream rice uses ("|HMC").
      dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";

      # --- The GTK4 / libadwaita half ------------------------------------
      #
      # libadwaita apps ignore gtk-theme (adw_init() installs Adwaita's
      # sheet). Only the *user* stylesheet ~/.config/gtk-4.0/gtk.css
      # outranks it (priority USER 800 vs THEME 200), and only on nodes
      # both match -- hence app-overrides.css for specific apps.
      #
      # assets/ comes along because the CSS references it relatively.
      #
      # If the `gtk` module is ever enabled here, gtk.gtk4.extraCss writes
      # the same path; move this into that option.
      xdg.configFile."gtk-4.0/gtk.css".source = userGtk4Css;
      xdg.configFile."gtk-4.0/assets".source = "${theme}/gtk-4.0/assets";

      # --- The GNOME Shell half ------------------------------------------
      #
      # Top bar, overview and menus are St widgets styled by gnome-shell's
      # compiled-in stylesheet; User Themes is the only supported way in
      # (see theme/gnome-shell/gnome-shell.css in the package). `name` is
      # the share/themes directory, same as gtk-theme.
      my.gnome-extensions.user-themes.enable = true;
      dconf.settings."org/gnome/shell/extensions/user-theme".name = "Oneshot";
    }

    (mkIf cfg.pixelFont {
      # The family really is "Terminus (TTF)" (see fc-list); a wrong name
      # silently falls back to the default sans.
      home.packages = [ pkgs.terminus_font_ttf ];
      dconf.settings."org/gnome/desktop/interface".font-name = "Terminus (TTF) 10";
    })
  ];
}
