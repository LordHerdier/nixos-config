# modules/features/dwl.nix
#
# dwl as a selectable login session. The compositor itself comes from
# pkgs/dwl (via the overlay in parts/overlay.nix), which is where patches
# and config.h live.
#
# Shows up as "dwl" in tuigreet's session list (F3), next to Hyprland and
# the gamescope Steam session. Needs the desktop-hyprland profile for the
# kitty / wofi that config.h launches.

{ pkgs, ... }:

let
  # Wallpaper cycling over swaybg; bound to Super+Alt+1/2/3 in pkgs/dwl/config.h.
  # Lives on PATH (systemPackages below) because the binds are plain SHCMDs.
  wallpaper = pkgs.writeShellApplication {
    name = "dwl-wallpaper";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.procps
      pkgs.swaybg
    ];
    text = builtins.readFile ./dwl-wallpaper.sh;
  };

  # Live-preview wallpaper menu (fzf in a centred kitty popup); Super+Alt+4.
  wallpaperPick = pkgs.writeShellApplication {
    name = "dwl-wallpaper-pick";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.fzf
      pkgs.kitty
      wallpaper
    ];
    text = builtins.readFile ./dwl-wallpaper-pick.sh;
  };

  # Opens or closes a centred kitty popup; config.h's MODAL() binds call it.
  modal = pkgs.writeShellApplication {
    name = "dwl-modal";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.kitty
      pkgs.procps
    ];
    text = builtins.readFile ./dwl-modal.sh;
  };

  # Region screenshot (Super+Shift+S); hyprshot needs hyprctl.
  screenshot = pkgs.writeShellApplication {
    name = "dwl-screenshot";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.grim
      pkgs.hyprpicker
      pkgs.libnotify
      pkgs.slurp
      pkgs.wl-clipboard
    ];
    text = builtins.readFile ./dwl-screenshot.sh;
  };

  # Night light toggle (Super+Shift+N), which Noctalia owns under Hyprland.
  nightlight = pkgs.writeShellApplication {
    name = "dwl-nightlight";
    runtimeInputs = [
      pkgs.libnotify
      pkgs.procps
      pkgs.util-linux
      pkgs.wlsunset
    ];
    text = builtins.readFile ./dwl-nightlight.sh;
  };

  # Notifications, which Noctalia owns under Hyprland. Started from
  # dwl-startup rather than put on PATH, so mako's D-Bus activation file
  # can't grab org.freedesktop.Notifications in a Hyprland session.
  # Colors follow colors[] in pkgs/dwl/config.h.
  makoConfig = pkgs.writeText "dwl-mako-config" ''
    font=monospace 12
    background-color=#000000
    text-color=#cbb8ff
    border-color=#9664ff
    border-size=1
    default-timeout=5000

    [urgency=high]
    border-color=#6442a5
    default-timeout=0
  '';

  # Runs inside the compositor (dwl -s). dwl exits when this process does,
  # so it must stay alive: `sleep infinity` holds the session open until
  # Super+Shift+Q. Add long-running helpers (bar, wallpaper, polkit agent)
  # above it with `&`.
  startup = pkgs.writeShellScript "dwl-startup" ''
    # Hand the compositor's environment to user services and D-Bus
    # activated apps (portals, notification daemons, ...).
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

    # The user manager outlives a logout, so portals started by a previous
    # session (e.g. Hyprland) are still running with its WAYLAND_DISPLAY
    # and XDG_CURRENT_DESKTOP, routing screencasts to that session's
    # backend. Stopping them lets D-Bus activation restart them on first
    # use with the environment imported above, which picks
    # dwl-portals.conf. Done again on exit for whichever session is next.
    stop_portals() {
      systemctl --user stop 'xdg-desktop-portal*.service' || true
    }
    stop_portals

    # Brings up graphical-session.target (hypridle, easyeffects), as
    # hyprland-session.target does under Hyprland. dwl SIGTERMs this
    # script on exit, which the trap turns into stopping the target again.
    trap 'systemctl --user stop dwl-session.target; stop_portals' EXIT
    trap 'exit 0' TERM
    systemctl --user start dwl-session.target

    ${wallpaper}/bin/dwl-wallpaper restore || true
    # Not hyprpolkitagent, which Hyprland uses: its hyprtoolkit renderer
    # aborts under dwl ("Couldn't open a gbm fd").
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    ${pkgs.mako}/bin/mako --config ${makoConfig} &

    # Not exec: the shell has to outlive sleep for the trap to run.
    sleep infinity &
    wait
  '';

  session = pkgs.writeShellScriptBin "dwl-session" ''
    export XDG_CURRENT_DESKTOP=dwl
    export XDG_SESSION_TYPE=wayland
    # dwl's bar reads its status line from stdin, so slstatus is piped in
    # (no exec: this is a pipeline; slstatus dies of SIGPIPE when dwl exits).
    ${pkgs.slstatus}/bin/slstatus -s | ${pkgs.dwl}/bin/dwl -s ${startup}
  '';

  sessionEntry =
    (pkgs.writeTextDir "share/wayland-sessions/dwl.desktop" ''
      [Desktop Entry]
      Name=dwl
      Comment=Dynamic window manager for Wayland
      Exec=${session}/bin/dwl-session
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "dwl" ];
      });
in
{
  services.displayManager.sessionPackages = [ sessionEntry ];

  # Started and stopped by dwl-startup. graphical-session.target refuses
  # a manual start, so this binds to it the way hyprland-session.target does.
  systemd.user.targets.dwl-session = {
    description = "dwl compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  # Screen sharing and screenshots for portal clients (browsers, Discord).
  # Hyprland ships its own hyprland-portals.conf; this is the dwl one,
  # picked by XDG_CURRENT_DESKTOP=dwl, so the two never compete.
  xdg.portal = {
    wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
    config.dwl = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };

  # dwl-session on PATH so the slstatus pipeline also applies when launching
  # from a TTY (plain `dwl` has no status input and shows the bar's default).
  environment.systemPackages = [
    pkgs.dwl
    session
    wallpaper
    wallpaperPick
    modal
    screenshot
    nightlight
    # Audio mixer popup (Super+A / bar status click in pkgs/dwl/config.h).
    pkgs.wiremix
    # Brightness and media keys in pkgs/dwl/config.h.
    pkgs.brightnessctl
    pkgs.playerctl
    # notify-send, for scripts and testing mako.
    pkgs.libnotify
  ];
}
