# home/modules/kid/gnome.nix
#
# Per-user GNOME tuning via dconf. Everything here is scoped to her
# account — none of it touches Charlotte's Hyprland session.

{ lib, pkgs, ... }:

let
  inherit (lib.hm.gvariant) mkArray mkTuple mkUint32;
in
{
  # dash-to-dock: a persistent taskbar is easier for her than the
  # Activities overview, and worth the extension-breakage risk. Not via
  # ../gnome-extensions, which only the desktop-gnome profile imports.
  home.packages = [ pkgs.gnomeExtensions.dash-to-dock ];

  dconf.settings = {
    # Most important setting here: the system default is colemak
    # (xkb.variant in modules/profiles/desktop-common.nix). GNOME takes its
    # layout from dconf, so this gives her QWERTY in her session only.
    #
    # NOTE: kmonad remaps at the evdev layer, so the built-in keyboard,
    # the SEM USB keyboard and the Keychron K6 (modules/common/kmonad)
    # stay colemak-with-homerow-mods regardless. Other keyboards get
    # true QWERTY.
    "org/gnome/desktop/input-sources" = {
      sources = mkArray "(ss)" [
        (mkTuple [
          "xkb"
          "us"
        ])
      ];
      xkb-options = mkArray "s" [ ];
    };

    "org/gnome/desktop/interface" = {
      # 1.25: readable without breaking layouts the way 1.5 does.
      text-scaling-factor = 1.25;
      cursor-size = 32;
      clock-format = "12h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-animations = true;
      # Accidental hot-corner overviews are confusing.
      enable-hot-corners = false;
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "kids-video.desktop"
        "steam-big-picture.desktop"
        "org.kde.gcompris.desktop"
        "tuxpaint.desktop"
        "org.gnome.Nautilus.desktop"
      ];
      # Only dash-to-dock; she can't install extensions herself.
      disable-user-extensions = false;
      enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-fixed = true;
      dock-position = "BOTTOM";
      extend-height = false;
      autohide = false;
      intellihide = false;
    };

    # One workspace: dynamic ones are the easiest way to "lose" a window.
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 1;
      button-layout = "appmenu:close";
    };

    # Never lock: unlocking would need an adult.
    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
      idle-activation-enabled = false;
    };
    "org/gnome/desktop/session".idle-delay = mkUint32 900;

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-battery-timeout = 1800;
      power-button-action = "interactive";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      natural-scroll = true;
      two-finger-scrolling-enabled = true;
    };

    # Big icons in Files, and no "move to trash forever" surprises.
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      show-delete-permanently = false;
    };
    "org/gnome/nautilus/icon-view".default-zoom-level = "large";

    # Keep search to apps and files.
    "org/gnome/desktop/search-providers".disabled = [
      "org.gnome.Software.desktop"
      "org.gnome.Settings.desktop"
    ];
  };
}
