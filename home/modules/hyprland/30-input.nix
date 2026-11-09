# home/modules/hyprland/30-input.nix

{ ... }:

{
  # `settings.config` sections from every module merge into a single
  # hl.config({ ... }) call; see also 40-design.nix.
  wayland.windowManager.hyprland.settings.config = {
    input = {
      # Colemak (first, so it's the login default) and QWERTY, for the
      # Super+Alt+K `switchxkblayout` toggle in binds.lua.
      kb_layout = "us,us";
      kb_variant = "colemak,";
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
