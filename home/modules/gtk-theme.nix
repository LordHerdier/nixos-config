# home/modules/gtk-theme.nix
#
# GTK theme for the tiling sessions (dwl, Hyprland), coloured from the
# runtime `my.theme` palette -- so it follows `theme-set wal` along with
# st-wl, the dwl bar, nvim and wofi.
#
#   theme   adw-gtk3-dark: GTK3 drawn like libadwaita, so both toolkits
#           share one set of named colours (@window_bg_color, ...).
#   colours a `gtk` fragment of @define-color lines, imported by both
#           ~/.config/gtk-3.0/gtk.css and gtk-4.0/gtk.css. The user
#           stylesheet is the only thing libadwaita apps let through.
#   icons   Papirus-Dark with grey folders: neutral, so they sit under
#           whatever accent the wallpaper produces.
#
# GTK4 does not import the theme's own gtk-4.0 sheet (gtk.gtk4.theme =
# null): libadwaita already is that look, and the import would only add
# a second layer under the fragment.
#
# Reloading: the hook flips gtk-theme away and back, which makes running
# GTK3 apps re-read their CSS. libadwaita apps pick the new colours up on
# their next start.
#
# GNOME hosts use oneshot-gtk.nix instead (dconf-driven, see its header).

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.gtk-theme;
  themeName = "adw-gtk3-dark";

  # Only pass-through colours: the fragment is `wal = true`, so anything
  # computed here would be computed on placeholders. GTK's own mix() and
  # alpha() do the derived shades at runtime instead.
  colours =
    t:
    let
      p = t.palette;
      r = t.roles;
    in
    ''
      @define-color accent_color ${r.accent};
      @define-color accent_bg_color ${r.accent};
      @define-color accent_fg_color ${r.accentFg};

      @define-color window_bg_color ${p.bg};
      @define-color window_fg_color ${p.fg};
      @define-color view_bg_color ${p.bg};
      @define-color view_fg_color ${p.fg};
      @define-color headerbar_bg_color ${r.surface};
      @define-color headerbar_fg_color ${p.fg};
      @define-color headerbar_backdrop_color @window_bg_color;
      @define-color headerbar_border_color ${r.borderInactive};
      @define-color sidebar_bg_color ${r.surface};
      @define-color sidebar_fg_color ${p.fg};
      @define-color sidebar_backdrop_color ${r.surface};
      @define-color sidebar_border_color ${r.borderInactive};
      @define-color secondary_sidebar_bg_color ${r.surface};
      @define-color secondary_sidebar_fg_color ${p.fg};
      @define-color card_bg_color mix(${p.bg}, ${p.fg}, 0.05);
      @define-color card_fg_color ${p.fg};
      @define-color dialog_bg_color ${r.surface};
      @define-color dialog_fg_color ${p.fg};
      @define-color popover_bg_color ${r.surface};
      @define-color popover_fg_color ${p.fg};
      @define-color thumbnail_bg_color ${r.surface};
      @define-color thumbnail_fg_color ${p.fg};

      @define-color destructive_color ${r.error};
      @define-color destructive_bg_color ${r.error};
      @define-color success_color ${r.success};
      @define-color success_bg_color ${r.success};
      @define-color warning_color ${r.warning};
      @define-color warning_bg_color ${r.warning};
      @define-color error_color ${r.error};
      @define-color error_bg_color ${r.error};
    '';

  # Square corners to match dwl's 1px borders; colours come from the
  # fragment. Shared by both toolkits.
  userCss = ''
    @import url("file://${config.my.theme.runtime.active}/gtk.css");

    window,
    window.csd,
    window.solid-csd,
    decoration,
    headerbar,
    .titlebar {
      border-radius: 0;
    }
  '';
in
{
  options.my.gtk-theme.enable = mkEnableOption "adw-gtk3 + Papirus, coloured from the runtime my.theme palette";

  config = mkIf cfg.enable {
    my.theme.fragments.gtk = {
      file = "gtk.css";
      wal = true;
      render = colours;
      reload = ''
        dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
        dconf write /org/gnome/desktop/interface/gtk-theme "'${themeName}'"
      '';
      runtimeInputs = [ pkgs.dconf ];
    };

    gtk = {
      enable = true;

      theme = {
        name = themeName;
        package = pkgs.adw-gtk3;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme.override { color = "grey"; };
      };

      colorScheme = config.my.theme.active.polarity;

      gtk3.extraCss = userCss;
      gtk4 = {
        theme = null;
        extraCss = userCss;
      };
    };
  };
}
