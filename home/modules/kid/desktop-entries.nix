# home/modules/kid/desktop-entries.nix
#
# The two launchers she actually uses, written into
# ~/.local/share/applications so they show up in the GNOME dash (see the
# favorite-apps list in gnome.nix).

{ pkgs, ... }:

{
  xdg.desktopEntries = {
    # Big Picture via plain `steam -tenfoot`: nesting gamescope inside
    # GNOME tends to give a black screen. The gamescope session is in
    # tuigreet's F3 list instead.
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

    # One click straight to video, no URL typing.
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
