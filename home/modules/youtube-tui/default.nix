# home/modules/youtube-tui/default.nix
#
# youtube-tui (github.com/Siriusmart/youtube-tui): Colemak movement matching
# nvf, kitty for anything that needs its own terminal, and mpv for playback
# with yt-dlp reading YouTube cookies out of Firefox.
#
# The four managed files below are read-only store symlinks, so main.yml
# sets `write_config: Dont`; otherwise youtube-tui tries to rewrite them on
# every start. Anything not managed here (appearance, pages, search,
# cmdefine, remaps) stays a normal file youtube-tui owns.
#
# Careful: a file that fails to parse gets *renamed* to `<name>-<date>.yml`
# and replaced with defaults, which would break the symlink.

{ lib, pkgs, ... }:

let
  ytdlRawOptions = "cookies-from-browser=firefox";

  yaml = pkgs.formats.yaml { };

  # Only the fields that differ from upstream; serde fills in the rest.
  main = {
    write_config = "Dont";
    # Replaces the upstream table outright, so every entry is restated.
    env = {
      youtube-downloader = "yt-dlp";
      download-path = "~/Downloads/%(title)s-%(id)s.%(ext)s";
      save-path = "~/.local/share/youtube-tui/saved/";
      browser = "xdg-open";
      terminal-emulator = "kitty";
      video-player = "mpv --ytdl-raw-options=${ytdlRawOptions}";
    };
  };

  # Generated defaults were already sitting in ~/.config/youtube-tui, so
  # take these paths over rather than tripping home-manager's clobber check.
  managed = src: {
    source = src;
    force = true;
  };
in
{
  home.packages = [
    pkgs.youtube-tui
    pkgs.mpv
    # Also needed on PATH by the libmpv youtube-tui links for in-app audio.
    pkgs.yt-dlp
  ];

  xdg.configFile = lib.mapAttrs' (name: src: lib.nameValuePair "youtube-tui/${name}" (managed src)) {
    "main.yml" = yaml.generate "youtube-tui-main.yml" main;
    "keybindings.yml" = ./keybindings.yml;
    "commandbindings.yml" = ./commandbindings.yml;
    "commands.yml" = pkgs.replaceVars ./commands.yml { inherit ytdlRawOptions; };
  };
}
