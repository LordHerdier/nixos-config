# home/modules/hyprland/30-input.nix

{ ... }:

{
  # Everything that was a top-level hyprlang section now lives under
  # `config`, which the modules merge into a single hl.config({ ... })
  # call. See 40-design.nix for the rest of it.
  wayland.windowManager.hyprland.settings.config = {
    input = {
      # Two layouts so the layout toggle in binds.lua can cycle between
      # them with `hyprctl switchxkblayout`; Colemak first, so it is
      # what you get at login. A single layout would leave nothing to
      # switch to.
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
