# modules/features/luciole.nix
#
# Luciole (noctalia-dev/luciole), a native Wayland file manager, for the dwl
# session on Index. The package and `programs.luciole` come from the flake's
# nixosModules.default (imported in parts/hosts.nix); this file is the
# settings. Super+Shift+E launches it (pkgs/dwl/config.h).
#
# GVfs (Trash, sftp/smb) is already on via ./gvfs.nix.
#
# charlotte's ~/.config/mimeapps.list used to be a hand-written file that
# apps edited. Home Manager owns it now (`force` replaces that file on the
# first activation), so the entries it held are carried over below; add
# new defaults here, not with xdg-mime / app dialogs, which would be undone
# by the next rebuild.

{ config, ... }:

{
  programs.luciole.enable = true;

  # Luciole as the Open/Save dialog for FileChooser portal clients. The
  # package registers its own backend; dwl's portal routing (./dwl/portals.nix)
  # only needs to prefer it, with gtk as the fallback.
  xdg.portal = {
    extraPortals = [ config.programs.luciole.package ];
    config.dwl."org.freedesktop.impl.portal.FileChooser" = [
      "luciole"
      "gtk"
    ];
  };

  home-manager.users.charlotte.xdg = {
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "dev.noctalia.luciole.desktop";

        "application/zip" = "org.gnome.Nautilus.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";

        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
        "x-scheme-handler/discord" = "legcord.desktop";
        "x-scheme-handler/discord-1216669957799018608" = "discord-1216669957799018608.desktop";
      };
      associations.added = {
        "audio/vnd.wave" = [
          "mpv.desktop"
          "audacity.desktop"
        ];
      };
    };
  };
}
