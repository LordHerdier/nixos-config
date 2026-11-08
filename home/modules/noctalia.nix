# home/modules/noctalia.nix
#
# noctalia 5.x. v5 merges two files:
#
#   config.toml    declarative, owned by this module, never written by
#                  the shell.
#   settings.toml  the Settings GUI's overrides, layered on top.
#
# A runtime tweak worth keeping can be read back out of settings.toml and
# moved here. `checkConfig` (on by default) runs `noctalia config
# validate` at build time, so unknown keys fail the build.
#
# Values were ported from the live v4 settings.json; see the notes at the
# bottom for what v5 couldn't take.

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

  # The launcher runs Terminal=true desktop entries via $TERMINAL, as a
  # bare executable (noctalia appends `-e` itself).
  home.sessionVariables.TERMINAL = "kitty";

  programs.noctalia = {
    enable = true;

    # Kept in the repo so they survive a fresh home.
    #
    # Must be path literals: the module treats a string as the file's
    # *contents*, so "${dir}/x.json" would produce a file whose body is a
    # store path. Only a real path is used as the source.
    customPalettes = {
      "Lilac AMOLED" = ./noctalia-palettes/lilac-amoled.json;
      "Halloween" = ./noctalia-palettes/halloween.json;
      "Neon Surf" = ./noctalia-palettes/neon-surf.json;
      "Rosey AMOLED" = ./noctalia-palettes/rosey-amoled.json;
    };

    settings = {
      accessibility.ui_scale = 1.1;

      shell = {
        telemetry_enabled = false;

        font_family = "DejaVu Sans Condensed";
        avatar_path = "${config.home.homeDirectory}/.face";
        clipboard_enabled = true;
        animation.speed = 1.25;
        shadow.direction = "down_right";

        # Placement is per-panel; v5 defaults the launcher and clipboard to
        # floating. The launcher stays floating, it works badly attached.
        panel = {
          launcher_placement = "floating";
          clipboard_placement = "attached";
          control_center_placement = "attached";
          wallpaper_placement = "attached";
          session_placement = "attached";
          transparency_mode = "soft";
          open_near_click_control_center = true;
        };

        launcher = {
          sort_by_usage = true;
          app_grid = true;
          categories = true;
          default_view = "all";
          width = 640;
        };

        # v5 has no built-in hibernate action, hence the command entry.
        session = {
          show_shortcuts = true;
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

      # "custom" rather than the identical community palette: resolved
      # from the repo, so it works offline on a fresh host.
      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "Lilac AMOLED";

        # True black surfaces; also shifts derived colours (hyprlock's
        # $outline renders 615088, not the palette's 4c3a70).
        pure_black_dark = true;

        # Renders hyprlock's colour file on every theme apply, startup
        # included; see hyprland/hyprlock-colors.nix.
        templates.enable_builtin_templates = false;
        templates.enable_community_templates = false;

        templates.user.hyprlock = {
          input_path = toString hlColors.template;
          output_path = hlColors.file;
        };
      };

      wallpaper = {
        enabled = true;
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        fill_mode = "crop";
        transition_duration = 800;
        edge_smoothness = 0.05;
        transition_on_startup = true;
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
          recursive = true;
        };
      };

      # v5 geocodes `address` only when auto_locate is off.
      location = {
        auto_locate = false;
        address = "Roxana";
      };

      weather = {
        enabled = true;
        unit = "fahrenheit";
        effects = true;
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

      # Unmodified wallpaper (v5 defaults are 0.5 / 0.3).
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
        enable_ddcutil = false;
        minimum_brightness = 0.05;
      };

      audio = {
        enable_overdrive = true;
      };

      system.monitor.enabled = true;

      # NOTE: duplicates hyprland/hypridle.nix, which already locks at
      # 300s and owns idle; only one should. Setting both `enabled`
      # flags below to false is the simple fix.
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

      dock = {
        enabled = false;
        position = "bottom";
        reserve_space = true;
        background_opacity = 1.0;
        active_monitor_only = true;
        launcher_position = "none";
        show_dots = false;
      };

      desktop_widgets.enabled = false;

      control_center = {
        sidebar = "compact";
      };

      bar.main = {
        position = "top";
        background_opacity = 0.44;
        shadow = false;
        capsule = true;
        capsule_opacity = 0.41;
        radius = 12;
        margin_edge = 4;
        margin_ends = 4;
        padding = 4;
        widget_spacing = 5;
        font_scale = 1.11;
        reserve_space = true;
        auto_hide = false;

        # v5's sysmon is one stat per instance, hence three.
        start = [
          "launcher"
          "settings"
          "wallpaper"
          "media"
          "sysmon-cpu-temp"
          "sysmon-cpu"
          "sysmon-ram"
        ];
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

        # Clicks/scroll on the bar's empty margin.
        dead_zone.actions = {
          right = "panel-toggle control-center";
          middle = "panel-toggle launcher";
          scroll_up = "workspace-switch next";
          scroll_down = "workspace-switch prev";
        };
      };

      # NOTE: inert -- `enabled` defaults to false and isn't set here.
      hot_corners.top_left.action = "launcher";

      widget = {
        launcher.glyph = "rocket";

        clock = {
          format = "{:%H:%M %a, %b %d}";
          vertical_format = "{:%H %M - %d %m}";
          tooltip_format = "{:%H:%M %a, %b %d}";
        };

        media = {
          max_length = 145;
          artist_first = true;
          title_scroll = "on_hover";
          hide_when_no_media = true;
        };

        active-window = {
          max_length = 300;
          title_scroll = "on_hover";
          display = "icon_and_text";
        };

        workspaces = {
          label_source = "id";
          max_label_chars = 2;
          pill_scale = 0.6;
          show_icons = true;
          labels_only_when_occupied = true;
          focused_color = "primary";
          occupied_color = "secondary";
          empty_color = "secondary";
        };

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
          drawer = true;
          hide_passive = false;
        };

        battery = {
          display_mode = "graphic";
          show_label = false;
          hide_if_not_detected = true;
        };

        # Icon-only: v5 has no hover-reveal label mode.
        network.show_label = false;
        bluetooth.show_label = false;
        volume.show_label = false;
        brightness.show_label = false;

        control-center.glyph = "noctalia";
      };
    };
  };
}

# v4 SETTINGS WITH NO v5 EQUIVALENT: a separate fixed-width font,
# audio.preferredPlayer, per-widget font weight/icon scale/badge colour,
# volume middle-click command, distro-logo control centre, the v4
# lock-screen chrome (v5 builds it from lockscreen widgets), and the
# tailscale/protonvpn/usb-drive-manager plugins (v5 plugins are a new
# system; ~/.config/noctalia/plugins/ doesn't carry over). The built-in
# `screenshot` widget partly covers v4's screen-toolkit plugin.
#
# LEFT IN settings.toml ON PURPOSE (runtime state that would only fight
# the shell for ownership):
#   wallpaper.last / wallpaper.monitors.*  what is on screen right now.
#   wallpaper.default.path                 churns with random automation.
#   lockscreen_widgets.*                   layout-editor output, pixel
#                                          geometry for one eDP-1; no
#                                          business in a shared module.
#   theme.builtin / theme.wallpaper_scheme the palette picker saves every
#                                          field; only `source`'s is live.
#   config_version                         the shell's own metadata.
