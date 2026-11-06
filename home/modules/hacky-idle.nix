# home/modules/hacky-idle.nix
#
# Lazy lifecycle for the hacky-* quickshell popups. Their own toggle scripts
# already start the popup on first use; nothing ever stops it. These wrappers
# run the real toggle, then (re)arm a transient user timer that kills that
# popup's quickshell after 5 minutes without a toggle. The next keypress
# starts it again. If the popup is still open when the timer fires it is
# closed along with the process -- 5 minutes without a toggle means idle.
#
# Binds call `hacky-tts-idle-toggle` / `hacky-launcher-idle-toggle`
# (see hyprland/binds.lua).

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
