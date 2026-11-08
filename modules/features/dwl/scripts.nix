# modules/features/dwl/scripts.nix
#
# The dwl-* helpers behind config.h's binds and the bar's click regions,
# standing in for what Noctalia does under Hyprland. Each NAME here is
# ./scripts/dwl-NAME.sh, built with its runtime inputs as `dwl-NAME`; the
# script's own header says what it does and which bind runs it.
#
# They all go on PATH (default.nix), since config.h and slstatus call them
# by name from plain shell commands.

{
  lib,
  pkgs,
  dwl,
  st,
  themes,
}:

let
  mkScript =
    name: s:
    pkgs.writeShellApplication {
      name = "dwl-${name}";
      runtimeInputs = s.deps;
      runtimeEnv = s.env or { };
      # A script with `pages` gets ./scripts/settings/PAGE.sh ahead of its own
      # file, so pages are plain function files rather than scripts of their own.
      text =
        lib.concatMapStrings (p: builtins.readFile ./scripts/settings/${p}.sh + "\n") (s.pages or [ ])
        + builtins.readFile ./scripts/dwl-${name}.sh;
    };

  # "emoji<TAB>name" for every fully-qualified emoji in Unicode's test file,
  # less the skin-tone variants, built once here rather than parsed per run.
  emojiList = pkgs.runCommand "dwl-emoji-list" { } ''
    sed -n 's/^[^#]*; fully-qualified *# \([^ ]*\) E[0-9.]* \(.*\)$/\1\t\2/p' \
      ${pkgs.unicode-emoji}/share/unicode/emoji/emoji-test.txt \
      | grep -v 'skin tone' > $out
  '';

  # "combo<TAB>action" for every bind in config.h's key table.
  bindsList = pkgs.runCommand "dwl-binds-list" { nativeBuildInputs = [ pkgs.gawk ]; } ''
    awk -f ${./scripts/dwl-binds.awk} ${../../../pkgs/dwl/config.h} > $out
  '';

  scripts = lib.mapAttrs mkScript {
    airpods.deps = with pkgs; [
      jq
      libnotify
      librepods
    ];

    binds = {
      deps = with pkgs; [ fzf ];
      env.DWL_BINDS_LIST = bindsList;
    };

    bar-refresh.deps = [ pkgs.procps ];

    caffeine.deps = with pkgs; [
      coreutils
      libnotify
      procps
      systemd
      util-linux
      scripts.bar-refresh
    ];

    calendar.deps = with pkgs; [
      coreutils
      util-linux
    ];

    clipboard.deps = with pkgs; [
      cliphist
      fzf
      util-linux
      wl-clipboard
      st
    ];

    # mako as a runtime input rather than on PATH; see startup.sh.
    dnd.deps = [
      pkgs.mako
      scripts.bar-refresh
    ];

    emoji = {
      deps = with pkgs; [
        coreutils
        fzf
        gawk
        gnugrep
        util-linux
        wl-clipboard
      ];
      env.DWL_EMOJI_LIST = emojiList;
    };

    modal.deps = [
      pkgs.coreutils
      pkgs.procps
      st
    ];

    # theme-set, which the appearance page calls, is not here: it comes from
    # the Home Manager profile, as the dwl-theme hook assumes.
    settings = {
      pages = [
        "common"
        "network"
        "sound"
        "display"
        "appearance"
        "notifications"
      ];
      deps = with pkgs; [
        bluez
        brightnessctl
        coreutils
        fzf
        gawk
        gnugrep
        gnused
        jq
        mako
        networkmanager
        power-profiles-daemon
        procps
        util-linux
        wireplumber
        wlr-randr
        scripts.airpods
        scripts.bar-refresh
        scripts.caffeine
        scripts.dnd
        scripts.modal
        scripts.nightlight
        scripts.powersave
      ];
      env.DWL_THEMES = themes;
    };

    nightlight.deps = with pkgs; [
      libnotify
      procps
      util-linux
      wlsunset
      scripts.bar-refresh
    ];

    notifications.deps = with pkgs; [
      coreutils
      fzf
      gnugrep
      jq
      mako
      scripts.dnd
    ];

    powersave.deps = with pkgs; [
      brightnessctl
      coreutils
      gawk
      jq
      libnotify
      wlr-randr
      scripts.bar-refresh
    ];

    record.deps = with pkgs; [
      coreutils
      fzf
      jq
      libnotify
      procps
      pulseaudio
      slurp
      util-linux
      wf-recorder
      wlr-randr
      scripts.modal
    ];

    screenshot.deps = with pkgs; [
      coreutils
      grim
      hyprpicker
      libnotify
      slurp
      wl-clipboard
    ];

    # DWL_BIN is the dwl to signal: one from before the colour-reload
    # patch would die of the SIGUSR2.
    theme = {
      deps = with pkgs; [
        coreutils
        gnused
        procps
      ];
      env = {
        DWL_BIN = lib.getExe' dwl "dwl";
        DWL_THEMES = themes;
      };
    };

    # qylock-lock comes from PATH (modules/features/qylock.nix), as Super+L's does.
    session-menu.deps = with pkgs; [
      coreutils
      fzf
      procps
      systemd
      util-linux
    ];

    wallpaper.deps = with pkgs; [
      coreutils
      findutils
      procps
      swaybg
    ];

    wallpaper-pick.deps = with pkgs; [
      coreutils
      fzf
      scripts.wallpaper
      st
    ];

    # wlrctl activates windows through dwl's 85-foreign-toplevel-management.patch.
    windows.deps = with pkgs; [
      fzf
      gnugrep
      wlrctl
    ];

    # DWL_BIN is the dwl to signal: one from before the layout-signal patch
    # would die of the SIGUSR1.
    xkb-switch = {
      deps = with pkgs; [
        coreutils
        procps
      ];
      env.DWL_BIN = lib.getExe' dwl "dwl";
    };
  };
in
scripts
