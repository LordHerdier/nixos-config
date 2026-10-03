# home/modules/hyprland/default.nix

{ dotfiles, pkgs, ... }:

{
  imports = [
    ./20-monitors.nix
    ./30-input.nix
    ./40-design.nix
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
    configType = "hyprlang";

    settings.exec-once = [
      "noctalia-shell"
      "hyprpolkitagent"
      # gnome-keyring is now started by PAM at login via
      # services.gnome.gnome-keyring.enable (system config).
      "sleep 2 && /etc/profiles/per-user/charlotte/bin/kitty zsh -i -c t"
    ];
  };
}
