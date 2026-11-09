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

    # Each entry renders one hl.on(event, fn) call. hypr-session stands in
    # for home-manager's systemd start/stop hooks (systemd.enable = false).
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
              -- gnome-keyring is started by PAM at login via
              -- services.gnome.gnome-keyring.enable (system config).

              hl.timer(function()
                hl.exec_cmd("kitty zsh -i -c t")
              end, { timeout = 2000, type = "oneshot" })
            end'')
        ];
      }
    ];
  };
}
