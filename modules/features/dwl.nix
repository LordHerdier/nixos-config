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

  # Runs inside the compositor (dwl -s). dwl exits when this process does,
  # so it must stay alive: `sleep infinity` holds the session open until
  # Super+Shift+Q. Add long-running helpers (bar, wallpaper, polkit agent)
  # above it with `&`.
  startup = pkgs.writeShellScript "dwl-startup" ''
    # Hand the compositor's environment to user services and D-Bus
    # activated apps (portals, notification daemons, ...).
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

    ${wallpaper}/bin/dwl-wallpaper restore || true

    exec sleep infinity
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

  # dwl-session on PATH so the slstatus pipeline also applies when launching
  # from a TTY (plain `dwl` has no status input and shows the bar's default).
  environment.systemPackages = [
    pkgs.dwl
    session
    wallpaper
    wallpaperPick
    # Audio mixer popup (Super+A / bar status click in pkgs/dwl/config.h).
    pkgs.wiremix
  ];
}
