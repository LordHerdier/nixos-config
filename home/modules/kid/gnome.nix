# home/modules/kid/gnome.nix
#
# Per-user GNOME tuning via dconf. Everything here is scoped to her
# account — none of it touches Charlotte's Hyprland session.

{ lib, ... }:

let
  inherit (lib.hm.gvariant) mkArray mkTuple mkUint32;
in
{
  dconf.settings = {
    # The single most important setting in this file. The system default
    # is colemak (services.xserver.xkb.variant in the hyprland profile),
    # which a six-year-old learning to read cannot use. GNOME takes its
    # layout from dconf rather than the X server defaults, so this gives
    # her plain QWERTY inside her session only.
    #
    # NOTE: this does NOT defeat kmonad. kmonad remaps the built-in
    # laptop keyboard at the evdev layer, below X/Wayland, so the
    # built-in keys stay colemak-with-homerow-mods no matter what dconf
    # says. kmonad only grabs platform-i8042-serio-0-event-kbd, so an
    # external USB keyboard is untouched and will be true QWERTY.
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
      # Bigger everything. 1.25 is a real readability win at her age
      # without breaking app layouts the way 1.5 starts to.
      text-scaling-factor = 1.25;
      cursor-size = 32;
      clock-format = "12h";
      clock-show-weekday = true;
      color-scheme = "default";
      enable-animations = true;
      # No hot corner: brushing the top-left by accident and having the
      # screen fly apart is confusing.
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
      # She has no way to install extensions and they only add failure
      # modes across GNOME upgrades.
      disable-user-extensions = true;
    };

    # One workspace. Dynamic workspaces are the most common way to
    # "lose" a window — you swipe, everything is gone, and there's no
    # obvious way back.
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 1;
      button-layout = "appmenu:close";
    };

    # Never lock. If the screen locks mid-cartoon she needs an adult to
    # type a password, which defeats the point of the account.
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

    # Search is a fast route to parts of the system she has no business
    # in; keep it to apps and files.
    "org/gnome/desktop/search-providers".disabled = [
      "org.gnome.Software.desktop"
      "org.gnome.Settings.desktop"
    ];
  };
}
