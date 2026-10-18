# home/modules/noctalia.nix
#
# noctalia 5.x.
#
# WHERE THESE VALUES CAME FROM. Under v4 this module only *seeded*
# ~/.config/noctalia/settings.json on first activation, because that file
# was the GUI's to own -- so the attrset here drifted away from the real
# config over months of GUI use and became, in effect, a stale comment.
# What is below is the live v4 settings.json ported to v5, not that
# attrset. See noctalia-palettes/ for the colour schemes it referenced.
#
# v5 makes the drift impossible: it reads two files and merges them.
#
#   config.toml    the declarative config. Never written by the shell.
#   settings.toml  the Settings GUI's overrides, layered on top.
#
# So this file owns config.toml and is authoritative, while the GUI still
# saves -- into settings.toml. A rebuild once again actually changes the
# config, and a runtime tweak you want to keep can be read back out of
# settings.toml and moved here.
#
# `checkConfig` (on by default) runs `noctalia config validate` against
# this at build time, so a key that does not exist in v5 fails the build
# rather than being silently ignored at runtime.
#
# NOT PORTED, because v5 has no equivalent -- see the migration notes at
# the bottom of this file.

{
  config,
  inputs,
  lib,
  ...
}:

let
  hlColors = config.my.hyprlock-colors;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  # v4 appLauncher.terminalCommand = "kitty -e". v5 drops that setting and
  # wraps Terminal=true desktop entries using $TERMINAL instead, which it
  # wants as a bare executable -- it appends `-e` itself.
  home.sessionVariables.TERMINAL = "kitty";

  programs.noctalia = {
    enable = true;

    # v4 kept these under colorschemes/<name>/<name>.json; v5 reads
    # palettes/<name>.json and the payload format is unchanged. Copied
    # into the repo so they survive a fresh home, which they would not
    # have as GUI-created files.
    #
    # Path literals, and they have to be: the module's generator takes a
    # string as the file's *contents*, so an interpolated
    # "${palettes}/x.json" lands in palettes/ as a file whose body is a
    # store path, which noctalia then fails to parse at column 1. Only a
    # real path hits its isPath branch and gets used as the source.
    customPalettes = {
      "Lilac AMOLED" = ./noctalia-palettes/lilac-amoled.json;
      "Neon Surf" = ./noctalia-palettes/neon-surf.json;
      "Rosey AMOLED" = ./noctalia-palettes/rosey-amoled.json;
    };

    settings = {
      # v4 general.scaleRatio = 1.1.
      accessibility.ui_scale = 1.1;

      shell = {
        telemetry_enabled = false;

        # v4 ui.fontDefault. ui.fontFixed ("CaskaydiaCove Nerd Font") has
        # no v5 counterpart -- there is one shell font family now.
        font_family = "DejaVu Sans Condensed";

        # v4 general.avatarImage.
        avatar_path = "/home/charlotte/.face";

        # v4 appLauncher.enableClipboardHistory = true.
        clipboard_enabled = true;

        # v4 general.animationSpeed = 1.25.
        animation.speed = 1.25;

        # v4 general.enableShadows + shadowDirection = "bottom_right".
        shadow.direction = "down_right";

        # v4 ui.panelsAttachedToBar = true -- v5 is per-panel, and
        # defaults the launcher and clipboard to floating.
        panel = {
          # Reverted to v5's default in the GUI -- v4's "everything on the
          # bar" did not survive contact with the new launcher.
          launcher_placement = "floating";
          clipboard_placement = "attached";
          control_center_placement = "attached";
          wallpaper_placement = "attached";
          session_placement = "attached";

          # v4 ui.translucentWidgets = true.
          transparency_mode = "soft";

          # v4 bar.rightClickFollowMouse = true -- the control centre
          # opened under the click rather than at the bar's centre.
          open_near_click_control_center = true;
        };

        launcher = {
          sort_by_usage = true; # v4 appLauncher.sortByMostUsed
          app_grid = true; # v4 appLauncher.viewMode = "grid"
          categories = true; # v4 appLauncher.showCategories
          default_view = "all";
          width = 640;
        };

        # v4 sessionMenu. The v4 list had `hibernate` and
        # `userspaceReboot`, which v5 does not know: hibernate becomes a
        # custom command entry, and userspaceReboot was disabled anyway
        # so it is simply dropped. v4's countdownEnabled + a global
        # countdownDuration of 10000ms is per-entry in v5.
        session = {
          show_shortcuts = true; # v4 showKeybinds
          actions = [
            {
              action = "lock";
              shortcut = "1";
              countdown_seconds = 10;
            }
            {
              action = "suspend";
              shortcut = "2";
              countdown_seconds = 10;
            }
            {
              action = "command";
              label = "Hibernate";
              glyph = "bedtime";
              command = "systemctl hibernate";
              shortcut = "3";
              countdown_seconds = 10;
            }
            {
              action = "reboot";
              shortcut = "4";
              countdown_seconds = 10;
            }
            {
              action = "logout";
              shortcut = "5";
              countdown_seconds = 10;
            }
            {
              action = "shutdown";
              shortcut = "6";
              countdown_seconds = 10;
              variant = "destructive";
            }
            {
              action = "reboot_uefi";
              shortcut = "7";
              countdown_seconds = 10;
            }
          ];
        };
      };

      # v4 colorSchemes.predefinedScheme = "Lilac AMOLED" -- one of the
      # custom schemes above, so source is "custom", not "builtin".
      theme = {
        mode = "dark"; # v4 darkMode = true
        source = "custom";
        custom_palette = "Lilac AMOLED";

        # True black surfaces. This is also why the generated hyprlock
        # $outline is 615088 rather than the palette's own 4c3a70.
        pure_black_dark = true;

        # Replaces hyprlock-colors.nix's jq pass over colors.json, which
        # v5 no longer writes. noctalia renders this itself on every
        # theme apply -- including at startup -- so the lock screen's
        # colours track the scheme without anything polling for them.
        templates.enable_builtin_templates = false;
        templates.enable_community_templates = false;

        templates.user.hyprlock = {
          input_path = toString hlColors.template;
          output_path = hlColors.file;
        };
      };

      wallpaper = {
        enabled = true;
        directory = "/home/charlotte/Pictures/Wallpapers";
        fill_mode = "crop";
        transition_duration = 800;
        edge_smoothness = 0.05;
        transition_on_startup = true;
        # All eleven, rather than v4's six.
        transition = [
          "diamond"
          "disc"
          "fade"
          "golden"
          "honeycomb"
          "melt"
          "pixel"
          "stripes"
          "vortex"
          "wipe"
          "zoom"
        ];
        automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
          # v4 wallpaper.viewMode = "recursive".
          recursive = true;
        };
      };

      # v4 location.name with autoLocate left on; v5 geocodes `address`
      # when auto_locate is off, which is what naming a place meant.
      location = {
        auto_locate = false;
        address = "Roxana";
      };

      weather = {
        enabled = true; # v4 location.weatherEnabled
        unit = "fahrenheit"; # v4 location.useFahrenheit
        effects = true; # v4 location.weatherShowEffects
      };

      notification = {
        position = "top_right";
        layer = "overlay";
        background_opacity = 1.0;
      };

      osd = {
        position = "top_right";
        layer = "overlay";
        hide_delay_ms = 2000;
        background_opacity = 1.0;
      };

      # v4 general.lockScreenBlur / lockScreenTint were both 0, i.e. the
      # wallpaper unmodified; v5 defaults them to 0.5 / 0.3.
      lockscreen = {
        enabled = true;
        blur_intensity = 0.0;
        tint_intensity = 0.0;
      };

      nightlight = {
        enabled = false;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      brightness = {
        enable_ddcutil = false; # v4 enableDdcSupport
        minimum_brightness = 0.05; # v4 enforceMinimum
      };

      audio = {
        enable_overdrive = true; # v4 audio.volumeOverdrive
      };

      system.monitor.enabled = true;

      # v4 idle was ENABLED live, with lockTimeout 600 -> qylock-lock and
      # a 10s fade. Ported faithfully, but note this duplicates
      # hyprland/hypridle.nix, which locks at 300s -- see the migration
      # notes below.
      idle = {
        pre_action_fade_seconds = 10.0;
        behavior = {
          lock = {
            enabled = true;
            timeout = 600;
            action = "lock";
          };
          screen-off = {
            enabled = true;
            timeout = 600;
            action = "screen_off";
          };
        };
      };

      # v4 dock was disabled live (the repo seed said otherwise).
      dock = {
        enabled = false;
        position = "bottom";
        reserve_space = true; # v4 displayMode = "exclusive"
        background_opacity = 1.0;
        active_monitor_only = true; # v4 onlySameOutput
        launcher_position = "none";
        show_dots = false;
      };

      # Configured in v4 but switched off, so the widget list is gone and
      # only the toggle carries over.
      desktop_widgets.enabled = false;

      control_center = {
        # v4 controlCenter.position = "close_to_bar_button".
        sidebar = "compact";
      };

      bar.main = {
        position = "top";
        # v4 ran an opaque bar with translucent capsules
        # (useSeparateOpacity); this is translucent throughout.
        background_opacity = 0.44;
        shadow = false;
        capsule = true;
        capsule_opacity = 0.41;
        radius = 12; # v4 frameRadius
        margin_edge = 4; # v4 marginVertical
        margin_ends = 4; # v4 marginHorizontal
        padding = 4; # v4 contentPadding
        widget_spacing = 5;
        font_scale = 1.11;
        reserve_space = true; # v4 enableExclusionZoneInset
        auto_hide = false; # v4 displayMode = "always_visible"

        # v4 SystemMonitor was one widget showing CPU temp, CPU usage and
        # RAM together; v5's sysmon is one stat per instance, so it
        # becomes three.
        start = [
          "launcher"
          "settings"
          "wallpaper"
          "media"
          "sysmon-cpu-temp"
          "sysmon-cpu"
          "sysmon-ram"
        ];
        # v4's plugin:privacy-indicator is a built-in widget in v5.
        center = [
          "workspaces"
          "clock"
          "active-window"
          "privacy"
        ];
        end = [
          "tray"
          "notifications"
          "battery"
          "power-profile"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "nightlight"
          "control-center"
        ];

        # v4 bar.{right,middle}ClickAction and mouseWheelAction, which
        # applied to the bar's empty margin rather than to a widget.
        dead_zone.actions = {
          right = "panel-toggle control-center";
          middle = "panel-toggle launcher";
          scroll_up = "workspace-switch next";
          scroll_down = "workspace-switch prev";
        };
      };

      # No v4 ancestor; new in v5. NOTE: `enabled` defaults to false and
      # nothing sets it, so this corner is configured but inert -- set
      # `enabled = true` here to actually arm it.
      hot_corners.top_left.action = "launcher";

      widget = {
        launcher.glyph = "rocket"; # v4 icon = "rocket"

        # v4 formatHorizontal/formatVertical/tooltipFormat were Qt date
        # formats; v5 uses strftime. "HH:mm ddd, MMM dd" -> below.
        clock = {
          format = "{:%H:%M %a, %b %d}";
          vertical_format = "{:%H %M - %d %m}";
          tooltip_format = "{:%H:%M %a, %b %d}";
        };

        media = {
          max_length = 145; # v4 maxWidth
          artist_first = true; # v4 showArtistFirst
          title_scroll = "on_hover"; # v4 scrollingMode = "hover"
          hide_when_no_media = true; # v4 hideMode = "hidden"
        };

        active-window = {
          max_length = 300; # v4 maxWidth
          title_scroll = "on_hover"; # v4 scrollingMode = "hover"
          display = "icon_and_text"; # v4 showIcon + showText
        };

        workspaces = {
          label_source = "id"; # v4 labelMode = "index"
          max_label_chars = 2; # v4 characterCount
          pill_scale = 0.6; # v4 pillSize
          show_icons = true; # v4 showApplications
          labels_only_when_occupied = true;
          focused_color = "primary";
          occupied_color = "secondary";
          empty_color = "secondary";
        };

        # v4 compactMode + useMonospaceFont, split across the three
        # stats the single v4 widget displayed.
        sysmon-cpu-temp = {
          type = "sysmon";
          stat = "cpu_temp";
          visualization = "none";
        };
        sysmon-cpu = {
          type = "sysmon";
          stat = "cpu_usage";
          visualization = "none";
        };
        sysmon-ram = {
          type = "sysmon";
          stat = "ram_pct";
          visualization = "none";
        };

        tray = {
          pinned = [ "Discord" ];
          drawer = true; # v4 drawerEnabled
          hide_passive = false; # v4 hidePassive
        };

        battery = {
          # v4 displayMode = "graphic-clean": the battery shape with no
          # label on it.
          display_mode = "graphic";
          show_label = false;
          hide_if_not_detected = true;
        };

        # v4 displayMode = "onhover" on all four. v5 has no hover-reveal
        # label mode, so these are icon-only -- the nearest behaviour.
        network.show_label = false;
        bluetooth.show_label = false;
        volume.show_label = false;
        brightness.show_label = false;

        control-center.glyph = "noctalia";
      };
    };
  };
}

# MIGRATION NOTES -- v4 settings with no v5 equivalent.
#
# Dropped outright:
#   ui.fontFixed             v5 has a single shell font family.
#   audio.preferredPlayer    "mpv"; v5 [shell.mpris] only blacklists.
#   bar widget fontWeight,   no v5 counterpart.
#     iconScale, progress
#     ring, unread badge colour
#   Volume middleClickCommand ("pwvucontrol || pavucontrol").
#   ControlCenter useDistroLogo -- v5 takes a glyph, not a distro logo.
#   general.passwordChars, compactLockScreen, showSessionButtons-
#     OnLockScreen and the other v4 lock-screen chrome: v5's lock screen
#     is built from lockscreen widgets instead.
#   noctaliaPerformance      no v5 equivalent; the control-centre
#                            shortcut for it is gone too.
#
# Bar widgets that were v4 plugins with no v5 port:
#   plugin:tailscale, plugin:protonvpn, plugin:usb-drive-manager.
#   plugin:screen-toolkit is partly covered by the built-in `screenshot`
#   widget, which is not in the layout above -- add it if you want it.
#   v5's plugin system is incompatible with v4's (it installs
#   <author>/<plugin> from api.noctalia.dev), so ~/.config/noctalia/
#   plugins/ cannot be carried over.
#
# LEFT IN settings.toml ON PURPOSE. These are GUI/runtime state, not
# config worth pinning, so folding them in here would only fight the
# shell for ownership:
#   wallpaper.last / wallpaper.monitors.*  what is on screen right now.
#   wallpaper.default.path                 churns, since automation is on
#                                          with order = "random".
#   lockscreen_widgets.*                   the layout editor's output:
#                                          disabled, and pixel geometry
#                                          specific to eDP-1 at
#                                          2160x1440, which has no
#                                          business in a module shared
#                                          by every Hyprland host.
#   theme.builtin / theme.wallpaper_scheme the Settings palette picker
#                                          saves all its fields; only the
#                                          one matching `source` is live,
#                                          so the other two are inert.
#   config_version                         the shell's own metadata.
#
# Also note theme.source: the GUI had selected "community" with
# community_palette = "Lilac AMOLED". That community palette is
# byte-identical to noctalia-palettes/lilac-amoled.json, so this keeps
# source = "custom" -- same colours, but resolved from the repo instead of
# refetched from api.noctalia.dev, which means it still works on a fresh
# host with no network. Switch the two lines if you would rather track
# the community copy and pick up any updates to it.
#
# Double idle management:
#   [idle] above is v4's live setting, which locks at 600s via
#   qylock-lock. hyprland/hypridle.nix ALSO manages idle and locks at
#   300s. Both were running under v4, so this is pre-existing rather than
#   something the port introduced -- but only one of them should own it.
#   hypridle is the one this config documents as the owner, so the
#   simplest fix is setting the two `enabled` flags above to false.
