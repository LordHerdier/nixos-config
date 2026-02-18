# home/modules/kitty.nix

{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.my.kitty;
in
{
  options.my.kitty = {
    enable = mkEnableOption "custom kitty configuration";

    opacity = mkOption {
      type = types.float;
      default = 0.4;
      description = "Background opacity for kitty.";
    };
  };

  config = mkIf cfg.enable {

    programs.kitty = {
      enable = true;

      font = {
        name = "CaskaydiaCove Nerd Font";
        size = 15;
      };

      settings = {
        # Fonts
        bold_font = "CaskaydiaCove Nerd Font";
        italic_font = "CaskaydiaCove Nerd Font";
        bold_italic_font = "CaskaydiaCove Nerd Font";

        # Text rendering
        adjust_line_height = "125%";
        disable_ligatures = "never";

        # Cursor
        cursor = "#bbbbbb";
        cursor_shape = "beam";
        cursor_beam_thickness = 1;
        cursor_blink_interval = 1;

        # Scrollback
        scrollback_lines = 50000;
        scrollback_pager = "less -R -F";

        # Mouse
        wheel_scroll_multiplier = "2.0";
        mouse_hide_wait = "3.0";
        pointer_shape_when_grabbed = "hand";
        default_pointer_shape = "arrow";
        pointer_shape_when_dragging = "beam";

        # URL handling
        url_color = "#0078d7";
        url_style = "single";
        open_url_with = "default";
        detect_urls = "yes";

        # Window behavior
        enabled_layouts = "splits";
        window_padding_width = "0 8 8";
        draw_minimal_borders = "yes";

        active_border_color = "#cba6f7";
        inactive_border_color = "#777777";

        # Tabs
        tab_bar_style = "powerline";
        tab_bar_edge = "top";
        tab_powerline_style = "round";
        tab_switch_strategy = "previous";

        # 🔥 Title = user@hostname
        tab_title_template =
          "${config.home.username}@${config.home.sessionVariables.HOSTNAME or config.home.username}";
        active_tab_title_template = "none";

        # Transparency
        background_opacity = toString cfg.opacity;

        # Theme (your palette)
        background = "#161926";
        foreground = "#CDD6F4";
        selection_background = "#44475a";
        selection_foreground = "none";

        color0  = "#45475A";
        color1  = "#F38BA8";
        color2  = "#A6E3A1";
        color3  = "#F9E2AF";
        color4  = "#89B4FA";
        color5  = "#F5C2E7";
        color6  = "#94E2D5";
        color7  = "#BAC2DE";
        color8  = "#585B70";
        color9  = "#F38BA8";
        color10 = "#A6E3A1";
        color11 = "#F9E2AF";
        color12 = "#89B4FA";
        color13 = "#F5C2E7";
        color14 = "#94E2D5";
        color15 = "#A6ADC8";

        editor = "vim";
        allow_remote_control = "yes";
        allow_hyperlinks = "yes";
        term = "xterm-kitty";
      };

      keybindings = {
        "ctrl+v" = "paste_from_clipboard";
        "ctrl+c" = "copy_and_clear_or_interrupt";
        "ctrl+backspace" = "send_text all \\x17";

        "ctrl+shift+k" = "scroll_line_up";
        "ctrl+shift+j" = "scroll_line_down";

        "ctrl+t" = "new_tab";
        "ctrl+q" = "close_tab";

        "ctrl+=" = "increase_font_size";
        "ctrl+-" = "decrease_font_size";
        "ctrl+KP_0" = "restore_font_size";
      };
    };
  };
}


