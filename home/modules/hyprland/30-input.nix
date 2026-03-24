# home/modules/hyprland/30-input.nix

{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us";
      kb_variant = "colemak";
      kb_rules = "";
      kb_model = "";
      follow_mouse = 1;
      sensitivity = 0;
      touchpad = {
        natural_scroll = true;
        disable_while_typing = true;
      };
    };

    cursor = {
      no_hardware_cursors = true;
    };
  };
}
