# home/modules/hyprland/default.nix

{
  dotfiles,
  lib,
  pkgs,
  ...
}:

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
    hyprshot
    mpvpaper
  ];

  home.file.".config/eww" = {
    source = "${dotfiles}/eww/.config/eww";
    recursive = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

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
              hl.exec_cmd("noctalia")
              hl.exec_cmd("hyprpolkitagent")
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
