# modules/features/sunshine.nix
# Sunshine self-hosted game stream host, for Moonlight clients to connect to.
#
# Runs as a user unit tied to graphical-session.target, so it only comes up
# once a session is logged in.
#
# Never let an RDP session share this session's Mutter. With RDP attached
# to it (rdp.nix's old headless mode: a virtual monitor next to the TV) and
# Sunshine streaming, apthos-display-sync's ApplyMonitorsConfig segfaulted
# GNOME Shell (meta_stage_view_inhibit_cursor_overlay via
# on_monitors_changed), taking Sunshine and the portals down with it.
# rdp.nix's system mode gives each RDP client its own GDM session and
# Mutter; keep it that way.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Matches the TV's refresh rate / HDR to the connecting Moonlight client
  # (VRR off while streaming) and restores the native mode afterwards. The
  # script explains why resolution isn't matched.
  displaySync = pkgs.writers.writePython3Bin "apthos-display-sync" {
    libraries = [ pkgs.python3Packages.pygobject3 ];
    flakeIgnore = [
      "E501" # long lines are fine
      "E402" # gi.require_version() must run before the gi.repository import
    ];
  } (builtins.readFile ./apthos-display-sync.py);

  streamPortBase = config.services.sunshine.settings.port;
  # The UDP stream ports, same offsets as nixpkgs' sunshine firewall rules.
  # They're only bound while a client is streaming, so their absence means
  # no one's connected.
  streamPortOffsets = [
    9
    10
    11
    13
    21
  ];

  # Sunshine's global_prep_cmd "undo" is unreliable across reconnects/drops
  # (github.com/LizardByte/Sunshine/issues/3481 and #1456); here it fired
  # once and never again. Backstop: if the display was switched and no
  # client is connected, revert.
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

  # nixpkgs builds Sunshine with SUNSHINE_ENABLE_CUDA=false unless
  # cudaSupport is set. Without CUDA, make_avcodec_encode_device() falls back
  # to a software encode device while PipeWire capture still negotiates
  # DMA-BUF (that check isn't behind the same #ifdef), so every frame fails
  # in sws_scale ("Couldn't scale frame: Invalid argument"): black picture,
  # working input, and several GB of leaked RSS from encoder rebuilds.
  sunshinePackage =
    (pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages;
    }).overrideAttrs
      (_: {
        # NVENC dlopen()s libcuda.so.1, which on NixOS lives only under the
        # driver runpath. Without it every nvenc probe fails ("Cannot load
        # libcuda.so.1") and the `encoder = "nvenc"` pin below silently
        # falls through to the flaky hevc_vulkan it exists to avoid.
        #
        # Must be in the wrapper, not the unit's environment: nixpkgs'
        # cudaSupport postFixup does `--set LD_LIBRARY_PATH <vulkan-loader>`,
        # discarding anything systemd set.
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

    # GNOME captures via the portal's ScreenCast + PipeWire, not KMS, so no
    # CAP_SYS_ADMIN.
    #
    # NOTE: the first ScreenCast request needs someone to click "Share"
    # locally once (no headless bypass). After a rebuild, approve it from
    # the Proxmox console before expecting a picture; GNOME remembers it.
    capSysAdmin = false;

    settings = {
      sunshine_name = "Apthos";

      # The default probe order tries hevc_vulkan before NVENC, and FFmpeg's
      # Vulkan encode on NVIDIA works for the first session then fails every
      # later one ("Device does not support the VK_KHR_video_encode_queue
      # extension!").
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

    # The user service runs with no PATH (nixpkgs' module, for its tray
    # links), so commands must be absolute store paths.
    #
    # Big Picture is "detached": fired once and not tracked, so Sunshine
    # streams the desktop under it and disconnecting doesn't kill Steam.
    applications.apps = [
      { name = "Desktop"; }
      {
        name = "Steam Big Picture";
        detached = [
          "${pkgs.util-linux}/bin/setsid ${config.programs.steam.package}/bin/steam steam://open/bigpicture"
        ];
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
