# home/modules/hyprland/default.nix

{
  dotfiles,
  lib,
  pkgs,
  ...
}:

let
  hyprSession = pkgs.writeShellApplication {
    name = "hypr-session";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dbus
      pkgs.systemd
    ];
    text = builtins.readFile ./session.sh;
  };
in
{
  imports = [
    ./20-monitors.nix
    ./30-input.nix
    ./40-design.nix
    ./45-crt.nix
    ./50-binds.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprlock-colors.nix
  ];

  home.packages = with pkgs; [
    hyprcursor
    # Super+Shift+C colour picker, and the freeze hyprshot -z shells out to.
    hyprpicker
    hyprshot
    mpvpaper
  ];

  # Stands in for home-manager's systemd integration (disabled below), so a
  # second session can't stop the first one's graphical-session.target.
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
      PropagatesStopTo = [ "graphical-session.target" ];
    };
  };

  home.file.".config/eww" = {
    source = "${dotfiles}/eww/.config/eww";
    recursive = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false;

    # Was `settings.exec-once`, which has no Lua equivalent: startup
    # commands are a subscription to the hyprland.start event. A list
    # rather than an attrset because home-manager emits its own
    # hl.on("hyprland.start", ...) for the systemd/D-Bus activation
    # environment, and both have to coexist.
    settings.on = [
      {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("${hyprSession}/bin/hypr-session start")
            end'')
        ];
      }
      {
        _args = [
          "hyprland.shutdown"
          (lib.generators.mkLuaInline ''
            function()
              os.execute("${hyprSession}/bin/hypr-session stop && sleep 0.1")
            end'')
        ];
      }
      {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("noctalia")
              hl.exec_cmd("hyprpolkitagent")
              -- The setcap wrapper (modules/features/librepods.nix), not
              -- the plain store binary: it needs cap_net_admin. librepods-ctl
              -- only works while this is running. --hide keeps the window
              -- closed (tray only) at startup.
              hl.exec_cmd("/run/wrappers/bin/librepods --hide")
              -- gnome-keyring is started by PAM at login via
              -- services.gnome.gnome-keyring.enable (system config).

              -- Was `sleep 2 && <abs path to kitty>`: a real timer, and
              -- kitty off PATH now that no shell is in the way.
              hl.timer(function()
                hl.exec_cmd("kitty zsh -i -c t")
              end, { timeout = 2000, type = "oneshot" })
            end'')
        ];
      }
    ];
  };
}
