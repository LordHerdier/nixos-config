# modules/features/sunshine.nix
# Sunshine self-hosted game stream host, for Moonlight clients to connect to.
#
# Runs as a per-user systemd unit tied to graphical-session.target, so it
# only comes up once a Wayland/X session (e.g. GNOME via SDDM) is
# actually logged in and running.

{ config, pkgs, ... }:

let
  # Matches the TV's refresh rate / HDR to whatever a connecting Moonlight
  # client asked for, and restores the native mode when it disconnects.
  # See the script itself for why resolution and VRR aren't part of this.
  displaySync = pkgs.writers.writePython3Bin "apthos-display-sync" {
    libraries = [ pkgs.python3Packages.pygobject3 ];
    flakeIgnore = [
      "E501" # long lines are fine
      "E402" # gi.require_version() must run before the gi.repository import
    ];
  } (builtins.readFile ./apthos-display-sync.py);

  streamPortBase = config.services.sunshine.settings.port;
  # Video/control/audio/mic/RTSP-setup ports -- same offsets used for the
  # firewall rules in nixpkgs' sunshine module. Sunshine only has these UDP
  # sockets bound while a client is actually streaming, so their absence is
  # a reliable "no one's connected" signal.
  streamPortOffsets = [
    9
    10
    11
    13
    21
  ];

  # Sunshine's global_prep_cmd "undo" is supposed to revert the display when
  # a session ends, but in practice it's unreliable across reconnects/drops
  # (see e.g. github.com/LizardByte/Sunshine/issues/3481 and #1456) -- it
  # fired once and then silently never again on this box. This timer is an
  # independent backstop: if we've switched away from native and no client
  # is actually connected any more, revert regardless of whether Sunshine
  # ever calls undo.
  displayWatchdog = pkgs.writeShellApplication {
    name = "apthos-display-watchdog";
    runtimeInputs = [ pkgs.iproute2 ];
    text = ''
      state_file="$HOME/.local/state/sunshine-display-sync.json"
      [ -f "$state_file" ] || exit 0

      active_ports=$(ss -uln | awk 'NR>1 { n=split($5,a,":"); print a[n] }')
      for offset in ${toString streamPortOffsets}; do
        port=$((${toString streamPortBase} + offset))
        if grep -qx "$port" <<<"$active_ports"; then
          exit 0 # a stream port is still bound -- client is connected
        fi
      done

      exec ${displaySync}/bin/apthos-display-sync stop
    '';
  };
in

{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = true;

    # GNOME (mutter) captures via the xdg-desktop-portal ScreenCast
    # interface + PipeWire rather than raw DRM/KMS, so no CAP_SYS_ADMIN
    # is needed here (that was only for Hyprland's wlroots capture path).
    #
    # NOTE: the portal's first ScreenCast request needs someone logged
    # in locally to click "Share" once — there's no headless bypass. On
    # an autologin/streaming box like this, log in once after a rebuild
    # (e.g. via the Proxmox console) and approve the prompt before
    # expecting Moonlight to show a picture; GNOME remembers the grant
    # after that.
    capSysAdmin = false;

    settings = {
      sunshine_name = "Apthos";

      # Sunshine's default encoder probe order tries Vulkan-Video (hevc_vulkan)
      # before NVENC. FFmpeg's Vulkan Video encode path is still flaky on
      # NVIDIA/Linux: it can succeed on the very first session and then fail
      # every session after with "Device does not support the
      # VK_KHR_video_encode_queue extension!", even though the GPU and driver
      # both support it fine via NVENC directly. Pin to nvenc to skip the
      # Vulkan path entirely.
      encoder = "nvenc";

      # Runs for every app/session, not just a specific one. Sunshine passes
      # SUNSHINE_CLIENT_WIDTH/HEIGHT/FPS/HDR to the "do" command.
      global_prep_cmd = builtins.toJSON [
        {
          do = "${displaySync}/bin/apthos-display-sync start";
          undo = "${displaySync}/bin/apthos-display-sync stop";
        }
      ];
    };

    # The sunshine systemd user service runs with no PATH (see nixpkgs'
    # sunshine module — needed for its tray icon links to work), so every
    # command below must be an absolute store path.
    #
    # Big Picture uses Steam's own "detached" launch: it's fired once and
    # not tracked, so Sunshine just streams the desktop underneath it same
    # as the "Desktop" app, and disconnecting doesn't kill Steam.
    applications.apps = [
      { name = "Desktop"; }
      {
        name = "Steam Big Picture";
        detached = [ "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture" ];
      }
    ];
  };

  systemd.user.services.apthos-display-watchdog = {
    description = "Revert Apthos's display if Sunshine's undo hook missed it";
    partOf = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${displayWatchdog}/bin/apthos-display-watchdog";
  };

  systemd.user.timers.apthos-display-watchdog = {
    description = "Poll for a stuck Sunshine display switch";
    wantedBy = [ "timers.target" ];
    partOf = [ "graphical-session.target" ];
    timerConfig = {
      OnActiveSec = "1m";
      OnUnitActiveSec = "1m";
    };
  };
}
