# home/modules/spotify-player.nix

{
  config,
  pkgs,
  isWsl,
  ...
}:

let
  t = config.my.theme.active;
  p = t.palette;
in
{
  programs.spotify-player = {
    enable = true;
    package = pkgs.spotify-player;

    # app.toml — point at our theme + WSL-friendly defaults
    settings = {
      theme = t.name;
      enable_streaming = if isWsl then "Never" else "Always";
      enable_media_control = true;
      enable_notify = false;
      playback_window_position = "Bottom";
      copy_command = {
        command = "wl-copy";
        args = [ ];
      };
    };

    # keymap.toml — Colemak navigation matching nvim/tmux
    keymaps = [
      # Movement: n/e/u/i = left/down/up/right
      {
        command = "SelectNextOrScrollDown";
        key_sequence = "e";
      }
      {
        command = "SelectPreviousOrScrollUp";
        key_sequence = "u";
      }
      {
        command = "FocusNextWindow";
        key_sequence = "i";
      }
      {
        command = "FocusPreviousWindow";
        key_sequence = "n";
      }

      # Page nav
      {
        command = "PageSelectNextOrScrollDown";
        key_sequence = "C-e";
      }
      {
        command = "PageSelectPreviousOrScrollUp";
        key_sequence = "C-u";
      }

      # Move NextTrack/PreviousTrack off n/p since n is now "left"
      {
        command = "NextTrack";
        key_sequence = "L";
      }
      {
        command = "PreviousTrack";
        key_sequence = "H";
      }

      # Disable the defaults we just stomped on so they don't double-fire
      {
        command = "None";
        key_sequence = "n";
      } # was NextTrack
      {
        command = "None";
        key_sequence = "p";
      } # was PreviousTrack

      # Disable exit commands so we don't clobber the session
      {
        command = "None";
        key_sequence = "q";
      }

      {
        command = "None";
        key_sequence = "C-c";
      }
    ];

    # theme.toml — built from my.theme so it tracks the system palette.
    # component_style below stays in spotify-player's own named-color
    # terms (Magenta, Cyan, ...), which resolve through the palette above
    # -- those are already role assignments, just spelled in ANSI names.
    themes = [
      {
        name = t.name;
        palette = {
          background = p.bg;
          foreground = p.fg;
          black = p.black;
          red = p.red;
          green = p.green;
          yellow = p.yellow;
          blue = p.blue;
          magenta = p.magenta;
          cyan = p.cyan;
          white = p.white;
          bright_black = p.brightBlack;
          bright_red = p.brightRed;
          bright_green = p.brightGreen;
          bright_yellow = p.brightYellow;
          bright_blue = p.brightBlue;
          bright_magenta = p.brightMagenta;
          bright_cyan = p.brightCyan;
          bright_white = p.brightWhite;
        };
        component_style = {
          block_title = {
            fg = "Magenta";
          };
          border = {
            fg = "BrightBlack";
          };
          playback_track = {
            fg = "Cyan";
            modifiers = [ "Bold" ];
          };
          playback_artists = {
            fg = "Yellow";
            modifiers = [ "Bold" ];
          };
          playback_album = {
            fg = "Magenta";
          };
          playback_progress_bar = {
            bg = "BrightBlack";
            fg = "Cyan";
          };
          current_playing = {
            fg = "Cyan";
            modifiers = [ "Bold" ];
          };
          selection = {
            fg = "Black";
            bg = "Cyan";
            modifiers = [ "Bold" ];
          };
          page_desc = {
            fg = "Cyan";
            modifiers = [ "Bold" ];
          };
          table_header = {
            fg = "Blue";
          };
          like = {
            fg = "Magenta";
          };
          lyrics_played = {
            fg = "BrightBlack";
          };
          lyrics_playing = {
            fg = "Yellow";
            modifiers = [ "Bold" ];
          };
          lyrics_unplayed = {
            fg = "White";
          };
        };
      }
    ];
  };
}
