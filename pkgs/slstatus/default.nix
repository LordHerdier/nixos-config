# pkgs/slstatus/default.nix
#
# slstatus with this repo's config.h, feeding dwl's bar through its stdin
# (see modules/features/dwl). Blocks slstatus can't produce itself are
# scripts in ./scripts, run through run_command; volume too, as slstatus's
# vol_perc is OSS/ALSA only.
#
# No colours are baked in: the scripts and config.h print dwl's theme colour
# names (^fg(accent), ^fg(alert), ...), which dwl resolves when it draws, so
# a dwl-theme switch recolours the blocks (99-theme-colours.patch).

{
  lib,
  slstatus,
  replaceVars,
  writeShellApplication,
  bluez,
  brightnessctl,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  libnotify,
  mako,
  networkmanager,
  pipewire,
  procps,
  sound-theme-freedesktop,
  wireplumber,
}:

let
  # ./scripts/slstatus-NAME.sh as `slstatus-NAME`, with the dwl colour
  # names it may print as SLSTATUS_ACCENT / _ALERT / _GOOD, and the low-battery
  # ping as SLSTATUS_PING.
  mkScript =
    name: deps:
    writeShellApplication {
      name = "slstatus-${name}";
      runtimeInputs = deps;
      runtimeEnv = {
        SLSTATUS_ACCENT = "accent";
        SLSTATUS_ALERT = "alert";
        SLSTATUS_GOOD = "good";
        SLSTATUS_PING = "${sound-theme-freedesktop}/share/sounds/freedesktop/stereo/dialog-warning.oga";
      };
      text = builtins.readFile ./scripts/slstatus-${name}.sh;
    };

  scripts = lib.mapAttrs mkScript {
    battery = [
      libnotify
      pipewire
    ];
    brightness = [
      brightnessctl
      coreutils
      gawk
      procps
    ];
    keyboard = [ ];
    network = [
      bluez
      coreutils
      gnused
      networkmanager
    ];
    notifications = [
      coreutils
      gnugrep
      mako
      procps
    ];
    volume = [
      gawk
      wireplumber
    ];
  };
in
slstatus.override {
  conf = replaceVars ./config.h (
    lib.mapAttrs (_: lib.getExe) scripts
    // {
      # wpctl's own @DEFAULT_AUDIO_SINK@ in the click commands, not ours
      DEFAULT_AUDIO_SINK = null;
    }
  );
}
