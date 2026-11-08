# home/modules/youtube-tui/default.nix
#
# youtube-tui (github.com/Siriusmart/youtube-tui): Colemak movement, kitty
# for anything that needs a terminal, mpv for playback with yt-dlp reading
# cookies from Firefox.
#
# appearance.yml is a my.theme runtime fragment (pywal included), read at
# startup; `:rc` re-reads it in a running instance.
#
# Managed files are read-only symlinks, hence `write_config: Dont`.
# Unmanaged ones (pages, search, cmdefine, remaps) stay youtube-tui's.
# Careful: a file that fails to parse gets *renamed* to `<name>-<date>.yml`
# and replaced with defaults, breaking the symlink.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.my.youtube-tui;
  follows = config.my.theme.follows cfg.palette;

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

  # Must stay wal-safe (see the `wal` fragment option): palette and role
  # colours passed straight through, and no accentDim.
  appearance =
    t:
    let
      p = t.palette;
      r = t.roles;
    in
    {
      borders = "Plain";
      colors = {
        text = p.fg;
        text_special = r.accent;
        text_secondary = r.muted;
        text_error = r.error;
        outline = r.borderInactive;
        outline_selected = r.border;
        outline_hover = p.magenta;
        outline_secondary = r.warning;
        message_outline = p.cyan;
        message_error_outline = r.error;
        message_success_outline = r.success;
        command_capture = r.success;
        item_info = {
          tag = r.muted;
          title = r.accent;
          description = r.muted;
          author = p.green;
          viewcount = p.yellow;
          length = p.cyan;
          published = p.magenta;
          video_count = p.brightBlue;
          sub_count = p.brightCyan;
          likes = p.brightGreen;
          genre = p.brightMagenta;
          page_turner = r.muted;
        };
      };
    };

  # JSON is YAML, and quoting every value keeps "#rrggbb" from reading
  # as a comment.
  renderAppearance = t: builtins.toJSON (appearance t) + "\n";

  # youtube-tui writes its own defaults on first run; take them over
  # rather than tripping home-manager's clobber check.
  managed = src: {
    source = src;
    force = true;
  };
in
{
  options.my.youtube-tui.palette = mkOption {
    type = types.enum (lib.attrNames config.my.theme.palettes);
    default = config.my.theme.default;
    defaultText = "config.my.theme.default";
    description = ''
      Which my.theme palette youtube-tui draws its colors from. Follows the
      system palette (and `theme-set`); set it to pin a different one.
    '';
  };

  # No reload hook: youtube-tui cannot be told to re-read from outside.
  config.my.theme.fragments.youtube-tui = lib.mkIf follows {
    file = "youtube-tui.yml";
    wal = true;
    render = renderAppearance;
  };

  config.home.packages = [
    pkgs.youtube-tui
    pkgs.mpv
    # Also needed on PATH by the libmpv youtube-tui links for in-app audio.
    pkgs.yt-dlp
  ];

  config.xdg.configFile =
    lib.mapAttrs' (name: src: lib.nameValuePair "youtube-tui/${name}" (managed src))
      {
        "main.yml" = yaml.generate "youtube-tui-main.yml" main;
        "keybindings.yml" = ./keybindings.yml;
        "commandbindings.yml" = ./commandbindings.yml;
        "commands.yml" = pkgs.replaceVars ./commands.yml { inherit ytdlRawOptions; };
        "appearance.yml" =
          if follows then
            config.lib.file.mkOutOfStoreSymlink "${config.my.theme.runtime.active}/youtube-tui.yml"
          else
            pkgs.writeText "youtube-tui-appearance.yml" (
              renderAppearance config.my.theme.palettes.${cfg.palette}
            );
      };
}
