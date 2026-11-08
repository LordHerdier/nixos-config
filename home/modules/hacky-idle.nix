# home/modules/hacky-idle.nix
#
# Lazy lifecycle for the hacky-* quickshell popups, which start on first
# toggle but never stop. These wrappers run the real toggle, then (re)arm a
# transient user timer that kills the popup's quickshell after 5 minutes
# without a toggle (even if it's still open).
#
# Bound in hyprland/binds.lua.

{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  mkIdleToggle =
    {
      name, # wrapper/unit name, e.g. hacky-tts
      pkg, # package providing bin/<name>-toggle and share/<name>/qml/Main.qml
    }:
    pkgs.writeShellApplication {
      name = "${name}-idle-toggle";
      runtimeInputs = [
        pkgs.procps
        pkgs.systemd
      ];
      text = ''
        ${pkg}/bin/${name}-toggle "$@"

        unit=${name}-idle
        # Replace any pending timer so every use restarts the 5 minute clock.
        systemctl --user stop "$unit.timer" "$unit.service" 2>/dev/null || true
        systemd-run --user --quiet --unit="$unit" --on-active=5m \
          pkill -f -- '${pkg}/share/${name}/qml/Main.qml' || true
      '';
    };
in
{
  config = {
    home.packages = [
      (mkIdleToggle {
        name = "hacky-launcher";
        pkg = inputs.hacky-launcher.packages.${system}.default;
      })
    ]
    ++ lib.optional config.my.hackyTts.enable (mkIdleToggle {
      name = "hacky-tts";
      pkg = inputs.hacky-tts.packages.${system}.default;
    });
  };
}
