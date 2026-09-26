# home/modules/kid/desktop-entries.nix
#
# The two launchers she actually uses, written into
# ~/.local/share/applications so they show up in the GNOME dash (see the
# favorite-apps list in gnome.nix).

{ pkgs, ... }:

{
  xdg.desktopEntries = {
    # Steam's couch UI: huge tiles, controller-navigable, no desktop
    # chrome. Plain `steam -tenfoot` rather than the gamescope session —
    # nesting gamescope inside an existing GNOME Wayland session is a
    # good way to get a black screen. The gamescope session is still
    # there at the tuigreet prompt under F3 if you want the full
    # console experience instead of GNOME.
    steam-big-picture = {
      name = "Games";
      comment = "Steam Big Picture";
      exec = "steam -tenfoot";
      icon = "steam";
      terminal = false;
      categories = [
        "Game"
      ];
    };

    # One click straight to video, so she never has to type a URL or
    # understand that Firefox and "videos" are different things.
    kids-video = {
      name = "Videos";
      comment = "YouTube Kids";
      exec = "${pkgs.firefox}/bin/firefox --new-window https://www.youtubekids.com/";
      icon = "firefox";
      terminal = false;
      categories = [
        "AudioVideo"
      ];
    };
  };
}
