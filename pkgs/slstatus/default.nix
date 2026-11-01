# pkgs/slstatus/default.nix
#
# slstatus with this repo's config.h, feeding dwl's built-in bar (dwl reads the
# status line from its stdin; see modules/features/dwl). Each block that
# slstatus can't produce itself is a script in ./scripts, run through
# run_command; the volume readout shells out to wpctl because slstatus's own
# vol_perc is OSS/ALSA only. The scripts print dwl's inline ^fg() colour
# commands (95-bar-status-commands.patch) so their colour follows the state.
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
  mako,
  networkmanager,
  procps,
  wireplumber,
}:

let
  # ./scripts/slstatus-NAME.sh as `slstatus-NAME`, with the dwl colour
  # names it may print as SLSTATUS_ACCENT / _ALERT / _GOOD.
  mkScript =
    name: deps:
    writeShellApplication {
      name = "slstatus-${name}";
      runtimeInputs = deps;
      runtimeEnv = {
        SLSTATUS_ACCENT = "accent";
        SLSTATUS_ALERT = "alert";
        SLSTATUS_GOOD = "good";
      };
      text = builtins.readFile ./scripts/slstatus-${name}.sh;
    };

  scripts = lib.mapAttrs mkScript {
    battery = [ ];
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
