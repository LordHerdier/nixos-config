# modules/features/luciole.nix
#
# Luciole (noctalia-dev/luciole), a native Wayland file manager, for the dwl
# session on Index. The package and `programs.luciole` come from the flake's
# nixosModules.default (imported in parts/hosts.nix); this file is the
# settings. Super+Shift+E launches it (pkgs/dwl/config.h).
#
# Colours: luciole watches ~/.config/luciole/colors.toml and re-applies it
# live. The `luciole` theme fragment below renders that file for every
# my.theme palette and for `theme-set wal` (which dwl-wallpaper.sh runs on
# each wallpaper change), and its reload hook drops the active one into
# place. The hook copies instead of symlinking: luciole only watches that
# directory, and `active` is repointed elsewhere. colors.toml is therefore
# generated, not hand-written.
#
# GVfs (Trash, sftp/smb) is already on via ./gvfs.nix.
#
# charlotte's ~/.config/mimeapps.list used to be a hand-written file that
# apps edited. Home Manager owns it now (`force` replaces that file on the
# first activation), so the entries it held are carried over below; add
# new defaults here, not with xdg-mime / app dialogs, which would be undone
# by the next rebuild.

{
  config,
  lib,
  pkgs,
  ...
}:

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

  home-manager.users.charlotte.my.theme.fragments.luciole = {
    file = "luciole-colors.toml";
    wal = true;
    # wal rules: palette and role colours passed straight through. The
    # containers can't be tonal steps of the accent (no maths), so the
    # surface layers use the ANSI black/brightBlack pair.
    render =
      t:
      let
        p = t.palette;
        r = t.roles;
        colors = {
          primary = r.accent;
          on_primary = r.accentFg;
          primary_container = r.selectionBg;
          on_primary_container = r.selectionFg;
          secondary = p.cyan;
          on_secondary = r.accentFg;
          secondary_container = r.surfaceAlt;
          on_secondary_container = p.fg;
          tertiary = p.magenta;
          on_tertiary = r.accentFg;
          tertiary_container = r.surfaceAlt;
          on_tertiary_container = p.fg;
          error = r.error;
          on_error = r.accentFg;
          error_container = r.surfaceAlt;
          on_error_container = r.error;
          surface = p.bg;
          on_surface = p.fg;
          on_surface_variant = p.white;
          surface_container_low = p.bg;
          surface_container = r.surface;
          surface_container_high = r.surfaceAlt;
          surface_container_highest = r.surfaceAlt;
          outline_variant = r.borderInactive;
          shadow = "#000000";
          scrim = "#000000";
          hover = r.selectionBg;
          on_hover = r.selectionFg;
        };
        table =
          name: "[${name}]\n" + lib.concatStrings (lib.mapAttrsToList (k: v: "${k} = \"${v}\"\n") colors);
      in
      # [colors] is what `color_scheme = "auto"` reads; [dark] covers a
      # pinned dark scheme.
      table "colors" + "\n" + table "dark";
    reload = ''
      dir="''${XDG_CONFIG_HOME:-$HOME/.config}/luciole"
      src="${config.home-manager.users.charlotte.my.theme.runtime.active}/luciole-colors.toml"
      mkdir -p "$dir"
      cp -L --no-preserve=mode "$src" "$dir/.colors.toml.tmp"
      mv -T "$dir/.colors.toml.tmp" "$dir/colors.toml"
    '';
    runtimeInputs = [ pkgs.coreutils ];
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
