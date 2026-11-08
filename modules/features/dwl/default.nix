# modules/features/dwl
#
# dwl as a selectable login session. The compositor itself comes from
# pkgs/dwl (via the overlay in parts/overlay.nix), which is where patches
# and config.h live; its bar's status line is pkgs/slstatus.
#
# Shows up as "dwl" in tuigreet's session list (F3), next to Hyprland and
# the gamescope Steam session. Needs the desktop-hyprland profile for the
# wofi that config.h launches; its terminal, st-wl, is built here.
#
# Colours (bar, borders, mako, slstatus) follow charlotte's
# `my.theme.default`, the same palette her kitty/wofi/nvim get on this
# host, so switching that one option recolours the session. dwl itself
# reads its colours at runtime, so that needs no restart, and `dwl-theme`
# switches its palette on the spot (scripts/dwl-theme.sh).
#
# | File           | Purpose                                                  |
# | -------------- | -------------------------------------------------------- |
# | `default.nix`  | Session entry, dwl-startup, systemd target, PATH         |
# | `scripts.nix`  | The dwl-* helpers in ./scripts and their runtime inputs  |
# | `startup.sh`   | dwl-startup: user services, mako, clipboard, tray apps   |
# | `mako.conf`    | Notification daemon config, coloured from `my.theme`     |
# | `portals.nix`  | xdg-desktop-portal routing for XDG_CURRENT_DESKTOP=dwl   |

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # The session user's resolved theme. Read across from Home Manager
  # rather than duplicated as a system option, so the two cannot drift.
  hm = config.home-manager.users.charlotte;
  t = hm.my.theme.active;

  # Colours are not an input: dwl reads them at runtime (/etc/dwl/colors,
  # below), so a palette change does not rebuild or restart it.
  dwl = pkgs.dwl;

  # What dwl's loadcolors (pkgs/dwl/patches/99-theme-colours.patch) reads,
  # one file per palette. The "# NAME" line is for dwl-theme.
  colorsText = name: theme: ''
    # ${name}
    bg=${theme.palette.bg}
    fg=${theme.palette.fg}
    surface=${theme.roles.surface}
    border_inactive=${theme.roles.borderInactive}
    muted=${theme.roles.muted}
    accent=${theme.roles.accent}
    accent_fg=${theme.roles.accentFg}
    border=${theme.roles.border}
    urgent=${theme.roles.error}
    success=${theme.roles.success}
  '';
  colorsFile = name: theme: pkgs.writeText "dwl-colors-${name}" (colorsText name theme);

  themes = pkgs.linkFarm "dwl-themes" (
    lib.mapAttrsToList (name: theme: {
      inherit name;
      path = colorsFile name theme;
    }) hm.my.theme.palettes
  );

  slstatus = pkgs.slstatus;

  # st-wl's compiled-in colours (pkgs/st-wl) are the my.theme palette as
  # built; they are only the fallback for when the st-colors fragment
  # (below) is missing. Live windows and new ones follow `theme-set`.
  st = pkgs.st-wl.override {
    colours = {
      inherit (t.palette)
        bg
        fg
        black
        red
        green
        yellow
        blue
        magenta
        cyan
        white
        brightBlack
        brightRed
        brightGreen
        brightYellow
        brightBlue
        brightMagenta
        brightCyan
        brightWhite
        ;
      cursor = t.roles.cursor;
      cursorRev = t.palette.brightBlack;
    };
  };

  scripts = import ./scripts.nix {
    inherit
      lib
      pkgs
      dwl
      st
      themes
      ;
  };

  # Same roles as the bar's colors[] (see `dwl` above). A fragment per
  # palette so `theme-set` can switch it (makoctl reload), and the default
  # one as a store file for a session where the state dir has nothing yet.
  makoConfig =
    theme:
    builtins.replaceStrings
      [ "@fg@" "@surface@" "@border@" "@error@" ]
      [ theme.palette.fg theme.roles.surface theme.roles.border theme.roles.error ]
      (builtins.readFile ./mako.conf);

  # Built without errexit: a step that fails must not end the session.
  startup = pkgs.writeShellApplication {
    name = "dwl-startup";
    bashOptions = [
      "nounset"
      "pipefail"
    ];
    runtimeInputs = [
      pkgs.cliphist
      pkgs.coreutils
      pkgs.dbus
      pkgs.mako
      pkgs.systemd
      pkgs.wl-clipboard
      scripts.caffeine
      scripts.wallpaper
    ];
    runtimeEnv = {
      DWL_MAKO_CONFIG = pkgs.writeText "mako-config" (makoConfig t);
      DWL_MAKO_ACTIVE = "${hm.my.theme.runtime.active}/mako";
      DWL_POLKIT_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    };
    text = builtins.readFile ./startup.sh;
  };

  session = pkgs.writeShellScriptBin "dwl-session" ''
    export XDG_CURRENT_DESKTOP=dwl
    export XDG_SESSION_TYPE=wayland
    # dwl's bar reads its status line from stdin, so slstatus is piped in
    # (no exec: this is a pipeline; slstatus dies of SIGPIPE when dwl exits).
    ${lib.getExe' slstatus "slstatus"} -s | ${lib.getExe' dwl "dwl"} -s ${lib.getExe startup}
  '';

  sessionEntry =
    (pkgs.writeTextDir "share/wayland-sessions/dwl.desktop" ''
      [Desktop Entry]
      Name=dwl
      Comment=Dynamic window manager for Wayland
      Exec=${lib.getExe session}
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "dwl" ];
      });
in
{
  imports = [ ./portals.nix ];

  services.displayManager.sessionPackages = [ sessionEntry ];

  # The same colours file as a fragment, so `theme-set wal` can fill it in;
  # the reload hook that hands it to dwl is in home/modules/theme/default.nix.
  home-manager.users.charlotte.my.theme.fragments.dwl-colors = {
    file = "dwl-colors";
    render = t: colorsText t.name t;
    wal = true;
  };

  # st-wl reads this at startup and on SIGUSR1 (pkgs/st-wl/patches/
  # 20-theme-colours.patch): "INDEX #rrggbb" per line, 0-15 the ANSI colours
  # and 256-259 cursor, reverse cursor, default background, default foreground.
  home-manager.users.charlotte.my.theme.fragments.st-colors = {
    file = "st-colors";
    wal = true;
    render =
      t:
      let
        p = t.palette;
        ansi = [
          p.black
          p.red
          p.green
          p.yellow
          p.blue
          p.magenta
          p.cyan
          p.white
          p.brightBlack
          p.brightRed
          p.brightGreen
          p.brightYellow
          p.brightBlue
          p.brightMagenta
          p.brightCyan
          p.brightWhite
        ];
        line = i: c: "${toString i} ${c}\n";
      in
      lib.concatStrings (
        lib.imap0 line ansi
        ++ [
          (line 256 t.roles.cursor)
          (line 257 p.brightBlack)
          (line 258 p.bg)
          (line 259 p.fg)
        ]
      );
    reload = "pkill -USR1 -x st-wl";
    runtimeInputs = [ pkgs.procps ];
  };

  home-manager.users.charlotte.my.theme.fragments.mako = {
    file = "mako";
    wal = true;
    render = makoConfig;
    reload = "makoctl reload";
    runtimeInputs = [ pkgs.mako ];
  };

  # my.theme.default as dwl's colours when charlotte has not picked another
  # with dwl-theme, and a rebuild that changes it recolours the live session.
  environment.etc."dwl/colors".source = colorsFile hm.my.theme.default t;
  system.activationScripts.dwl-recolour = {
    deps = [ "etc" ];
    text = ''
      ${lib.getExe scripts.theme} reload || true
    '';
  };

  # Started and stopped by dwl-startup. graphical-session.target refuses
  # a manual start, so this binds to it the way hyprland-session.target
  # (home/modules/hyprland/default.nix) does.
  systemd.user.targets.dwl-session = {
    description = "dwl compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    unitConfig.PropagatesStopTo = [ "graphical-session.target" ];
  };

  # dwl-session on PATH so the slstatus pipeline also applies when launching
  # from a TTY (plain `dwl` has no status input and shows the bar's default).
  environment.systemPackages = lib.attrValues scripts ++ [
    dwl
    session
    # The terminal config.h launches (pkgs/st-wl), coloured from `my.theme`.
    st
    # Audio mixer popup (Super+A / bar status click in pkgs/dwl/config.h).
    pkgs.wiremix
    # Brightness and media keys in pkgs/dwl/config.h.
    pkgs.brightnessctl
    pkgs.playerctl
    # Super+Shift+C colour picker (dwl-screenshot carries its own copy).
    pkgs.hyprpicker
    # notify-send, for scripts and testing mako.
    pkgs.libnotify
  ];
}
