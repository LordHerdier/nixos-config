# modules/features/sunshine.nix
# Sunshine self-hosted game stream host, for Moonlight clients to connect to.
#
# Runs as a per-user systemd unit tied to graphical-session.target, so it
# only comes up once a Wayland/X session (e.g. GNOME via SDDM) is
# actually logged in and running.
#
# Do not run this alongside gnome-remote-desktop-headless (modules/features/
# rdp.nix). Confirmed on this box: with an RDP client connected (so Mutter
# has a virtual monitor up alongside the TV's real one) and Sunshine also
# attached, a monitor reconfig -- the exact ApplyMonitorsConfig call
# apthos-display-sync makes below -- segfaulted GNOME Shell itself
# (crashed in mutter's meta_stage_view_inhibit_cursor_overlay, via
# on_monitors_changed), taking down the whole session: Sunshine, the
# portals, everything running under graphical-session.target. rdp.nix
# keeps the RDP service manual/on-demand specifically so this combination
# never happens; don't wire it back to start automatically without a real
# fix for the crash upstream.

{ config, lib, pkgs, ... }:

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
    runtimeInputs = [
      pkgs.iproute2
      pkgs.gawk
    ];
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

  # nixpkgs builds Sunshine with SUNSHINE_ENABLE_CUDA=false unless cudaSupport
  # is set (pkgs/by-name/su/sunshine/package.nix), and config.cudaSupport is
  # off by default. Without it SUNSHINE_BUILD_CUDA is never defined, so
  # make_avcodec_encode_device() has no CUDA branch to take and falls through
  # to a plain software encode device -- while the PipeWire capture side still
  # negotiates DMA-BUF buffers, because that decision only tests
  # `mem_type == cuda && display_is_nvidia` and is *not* behind the same
  # #ifdef. The software path then assigns a GPU buffer straight to
  # sws_input_frame->data[0], so every single frame dies in sws_scale with
  # "Couldn't scale frame: Invalid argument" / "Could not convert image":
  # Moonlight connects, input works (that's a separate path), and the picture
  # is black forever while Sunshine rebuilds the encoder per failed frame and
  # leaks its way to several GB of RSS. Enabling CUDA gives the DMA-BUF import
  # the encode device it has already negotiated for.
  sunshinePackage =
    (pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages;
    }).overrideAttrs
      (_: {
        # ffmpeg's NVENC path dlopen()s libcuda.so.1 at runtime instead of
        # linking it, and on NixOS that library lives only under the driver
        # symlink -- it is never on the default loader path (`ldconfig -p |
        # grep libcuda` comes back empty). Without it every nvenc probe died
        # on "Cannot load libcuda.so.1" / "Failed to create a CUDA device:
        # Operation not permitted", and the `encoder = "nvenc"` pin below then
        # silently fell through Sunshine's probe order to hevc_vulkan -- i.e.
        # straight into the flaky Vulkan path that pin exists to avoid.
        #
        # This has to ride in the wrapper rather than in the unit's
        # environment: nixpkgs' own cudaSupport postFixup wraps sunshine with
        # `--set LD_LIBRARY_PATH <vulkan-loader>`, which would discard
        # anything systemd put there.
        postFixup = ''
          wrapProgram $out/bin/sunshine \
            --set LD_LIBRARY_PATH ${
              lib.makeLibraryPath [ pkgs.vulkan-loader ]
            }:${pkgs.addDriverRunpath.driverLink}/lib
        '';
      });
in

{
  services.sunshine = {
    enable = true;
    package = sunshinePackage;
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
