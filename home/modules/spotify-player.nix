# home/modules/spotify-player.nix

{ pkgs, isWsl, ... }:

{
  programs.spotify-player = {
    enable = true;
    package = pkgs.spotify-player;

    # app.toml — point at our theme + WSL-friendly defaults
    settings = {
      theme = "kanagawa";
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

    # theme.toml — Kanagawa, matching your tmux palette
    themes = [
      {
        name = "kanagawa";
        palette = {
          background = "#1f1f28";
          foreground = "#dcd7ba";
          black = "#16161d";
          red = "#c34043";
          green = "#98bb6c";
          yellow = "#e6c384";
          blue = "#7e9cd8";
          magenta = "#d27e99";
          cyan = "#7fb4ca";
          white = "#c8c093";
          bright_black = "#727169";
          bright_red = "#e82424";
          bright_green = "#76946a";
          bright_yellow = "#ff9e3b";
          bright_blue = "#7fb4ca";
          bright_magenta = "#957fb8";
          bright_cyan = "#7aa89f";
          bright_white = "#dcd7ba";
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
