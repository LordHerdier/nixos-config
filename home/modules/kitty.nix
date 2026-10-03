# home/modules/kitty.nix

{
  config,
  lib,
  hostName,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.my.kitty;

  theme = config.my.theme.palettes.${cfg.palette};
  p = theme.palette;
  r = theme.roles;
in
{
  options.my.kitty = {
    enable = mkEnableOption "custom kitty configuration";

    opacity = mkOption {
      type = types.float;
      default = 0.8;
      description = "Background opacity for kitty.";
    };

    palette = mkOption {
      type = types.enum (lib.attrNames config.my.theme.palettes);
      default = config.my.theme.default;
      defaultText = "config.my.theme.default";
      description = ''
        Which my.theme palette kitty draws its colors from. Follows the
        system palette; set it to pin kitty to a different one.
      '';
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
        cursor = r.cursor;
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
        url_color = r.url;
        url_style = "single";
        open_url_with = "default";
        detect_urls = "yes";

        # Window behavior
        enabled_layouts = "splits";
        window_padding_width = "0 8 8";
        draw_minimal_borders = "yes";

        active_border_color = r.accent;
        inactive_border_color = r.borderInactive;

        # Tabs
        tab_bar_style = "powerline";
        tab_bar_edge = "top";
        tab_powerline_style = "round";
        tab_switch_strategy = "previous";

        # 🔥 Title = user@hostname
        tab_title_template = "${config.home.username}@${hostName}";
        active_tab_title_template = "none";

        # Transparency
        background_opacity = toString cfg.opacity;

        # Theme -- see my.kitty.palette
        background = p.bg;
        foreground = p.fg;
        selection_background = r.selectionBg;
        # Not a color: tells kitty to keep each cell's own foreground.
        selection_foreground = "none";

        color0 = p.black;
        color1 = p.red;
        color2 = p.green;
        color3 = p.yellow;
        color4 = p.blue;
        color5 = p.magenta;
        color6 = p.cyan;
        color7 = p.white;
        color8 = p.brightBlack;
        color9 = p.brightRed;
        color10 = p.brightGreen;
        color11 = p.brightYellow;
        color12 = p.brightBlue;
        color13 = p.brightMagenta;
        color14 = p.brightCyan;
        color15 = p.brightWhite;

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
