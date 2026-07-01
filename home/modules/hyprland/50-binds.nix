# home/modules/hyprland/50-binds.nix

{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";

    # Variables
    "$colorpicker" = "hyprpicker -qaf rgb";
    "$lock" = "qylock-lock";
    "$logout" = "hyprctl dispatch exit";
    "$screenshot" = "hyprshot --mode region --output-folder /tmp";
    "$wallScript" = "~/bin/wall_video";
    "$bindsMenu" = "~/bin/binds-menu";

    # Noctalia shell IPC (routed through the shell for OSD feedback)
    "$ipc" = "noctalia-shell ipc call";
    "$micMute" = "noctalia-shell ipc call volume muteInput";
    "$volUp" = "noctalia-shell ipc call volume increase";
    "$volDown" = "noctalia-shell ipc call volume decrease";
    "$volMute" = "noctalia-shell ipc call volume muteOutput";
    "$brightUp" = "noctalia-shell ipc call brightness increase";
    "$brightDown" = "noctalia-shell ipc call brightness decrease";

    # Apps
    "$browser" = "zen";
    "$calculator" = "qalculate-gtk";
    "$fileManager" = "thunar";
    "$ide" = "code";
    "$menu" = "noctalia-shell ipc call launcher toggle";
    "$mailApp" = "thunderbird";
    "$music" = "spotify-launcher";
    "$terminal" = "kitty";

    bind = [
      # Essentials
      "$mainMod, Q, killactive"
      "$mainMod, L, exec, $lock"
      "$mainMod SHIFT, L, exec, $logout"

      # Wallpapers
      "$mainMod ALT, 1, exec, $wallScript next"
      "$mainMod ALT, 2, exec, $wallScript prev"
      "$mainMod ALT, 3, exec, $ipc wallpaper random"

      # Launchers
      "$mainMod, SPACE, exec, $menu"
      "$mainMod, H, exec, $bindsMenu"
      "$mainMod, Return, exec, $terminal"
      "$mainMod, T, exec, [float] kitty"
      "$mainMod SHIFT, S, exec, $screenshot"
      "$mainMod SHIFT, C, exec, $colorpicker"
      "$mainMod, E, exec, thunar"
      "$mainMod, C, exec, code"
      "$mainMod, B, exec, zen-beta"
      "$mainMod, M, exec, spotify"

      # Noctalia launchers
      "$mainMod, V, exec, $ipc launcher clipboard"
      "$mainMod, period, exec, $ipc launcher emoji"
      "$mainMod, Tab, exec, $ipc launcher windows"
      "$mainMod SHIFT, SPACE, exec, $ipc launcher command"

      # Noctalia panels & menus
      "$mainMod, A, exec, $ipc controlCenter toggle"
      "$mainMod, O, exec, $ipc sessionMenu toggle"
      "$mainMod, W, exec, $ipc notifications toggleHistory"
      "$mainMod SHIFT, W, exec, $ipc notifications toggleDND"
      "$mainMod, comma, exec, $ipc settings toggle"
      "$mainMod, K, exec, $ipc calendar toggle"

      # Noctalia toggles
      "$mainMod SHIFT, B, exec, $ipc bar toggle"
      "$mainMod SHIFT, D, exec, $ipc darkMode toggle"
      "$mainMod SHIFT, N, exec, $ipc nightLight toggle"
      "$mainMod SHIFT, I, exec, $ipc idleInhibitor toggle"
      "$mainMod SHIFT, R, exec, $ipc plugin:screen-recorder toggle"

      # Window management
      "$mainMod, F, fullscreen"
      "$mainMod, P, pseudo"
      "$mainMod SHIFT, F, togglefloating"
      "$mainMod SHIFT, P, pin"

      # Focus (Colemak-based + arrow keys)
      "$mainMod, n, movefocus, l"
      "$mainMod, i, movefocus, r"
      "$mainMod, u, movefocus, u"
      "$mainMod, e, movefocus, d"
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # Workspaces
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      # Hardware keys
      ", XF86AudioRaiseVolume, exec, $volUp"
      ", XF86AudioLowerVolume, exec, $volDown"
      ", XF86AudioMute, exec, $volMute"
      ", XF86AudioMicMute, exec, $micMute"
      ", XF86AudioPlay, exec, $ipc media playPause"
      ", XF86AudioStop, exec, $ipc media stop"
      ", XF86AudioPrev, exec, $ipc media previous"
      ", XF86AudioNext, exec, $ipc media next"
      ", XF86MonBrightnessUp, exec, $brightUp"
      ", XF86MonBrightnessDown, exec, $brightDown"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
      "$mainMod SHIFT, mouse:272, resizewindow"
    ];
  };
}
