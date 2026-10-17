# home/modules/hyprland/20-monitors.nix

{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # The hyprlang CSV positions (output,mode,position,scale) are named
    # fields now; `scale = "auto"` and `mode = "preferred"` are the
    # strings that stand in for the old `auto`/`preferred` keywords.
    monitor = [
      # { output = "DP-2"; mode = "2560x1440@60"; position = "0x0"; scale = 1; }
      {
        output = "eDP-1";
        mode = "2880x1920@120";
        position = "0x0";
        scale = 1.33;
      }
      # { output = "eDP-1"; mode = "1920x1080@120"; position = "auto"; scale = 1; }
      {
        output = "DP-2";
        mode = "2560x1440@165";
        position = "0x-1440";
        scale = 1;
      }
      # Catch-all for an unknown output, and the same mirroring eDP-1:
      # { output = ""; mode = "1920x1080"; position = "auto"; scale = 1; }
      # { output = ""; mode = "1920x1080"; position = "auto"; scale = 1; mirror = "eDP-1"; }
    ];

    # Was `workspace = [ "2,monitor:DP-2" ... ]`. Order is preserved from
    # the hyprlang list rather than sorted, since that is what was tested.
    workspace_rule = [
      {
        workspace = "2";
        monitor = "DP-2";
      }
      {
        workspace = "1";
        monitor = "eDP-1";
      }
      {
        workspace = "4";
        monitor = "DP-2";
      }
      {
        workspace = "3";
        monitor = "eDP-1";
      }
      {
        workspace = "6";
        monitor = "DP-2";
      }
      {
        workspace = "5";
        monitor = "eDP-1";
      }
      {
        workspace = "8";
        monitor = "DP-2";
      }
      {
        workspace = "7";
        monitor = "eDP-1";
      }
      {
        workspace = "10";
        monitor = "DP-2";
      }
      {
        workspace = "11";
        monitor = "eDP-1";
      }
    ];
  };
}
