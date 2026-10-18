# home/modules/hyprland/hyprlock-colors.nix
#
# Bridges noctalia's runtime colors into hyprlock.
#
# On the Hyprland hosts the desktop's colors are noctalia's to decide --
# it derives them from the wallpaper (or the selected palette) and
# re-resolves them whenever the scheme changes. `my.theme` does not
# compete with that; see home/modules/theme/default.nix.
#
# hyprlock cannot read noctalia's theme, so it needs the hyprlang
# variable file this module is about. What that replaced was a line
# pointing at ~/.config/Ax-Shell/config/hypr/colors.conf -- a leftover
# from the shell this config used before noctalia. That file is still on
# disk on hosts that ran Ax-Shell, so the lock screen wasn't visibly
# broken; it was quietly frozen on a palette from a shell that is no
# longer installed, and on a fresh host the source would simply fail.
#
# HOW IT IS WRITTEN. Under noctalia v4 this module parsed
# ~/.config/noctalia/colors.json with jq, because that file was always
# written and -- settings.json being GUI-owned after first activation --
# noctalia's own template system could not be switched on declaratively.
# v5 removes both halves of that: there is no colors.json any more, and
# config.toml *is* declarative (see noctalia.nix), so the template is now
# the straightforward answer. noctalia renders
# noctalia-colors.conf.tmpl into the file below on every theme apply,
# startup included. The template entry itself lives in noctalia.nix,
# which owns `programs.noctalia.settings`; this module owns the template
# and the path, and exports both.
#
# WHAT THE GENERATOR IS STILL FOR. Exactly one case: the file not
# existing yet, on a host where noctalia has never run. hyprlock parses
# its config at launch and `source`-ing a missing file is fatal, so a
# cold start would otherwise be a lock screen that will not come up.
# It writes the declared palette as a fallback and -- importantly --
# never overwrites a file noctalia has already rendered.
#
# WHY NO inotify WATCH. noctalia rewrites the file itself now, and
# hyprlock only has to find it correct at launch.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;

  t = config.my.theme.active;
  p = t.palette;
  r = t.roles;

  out = "${config.xdg.configHome}/hypr/noctalia-colors.conf";

  template = ./noctalia-colors.conf.tmpl;

  # Used only when noctalia has never rendered the file -- a fresh
  # install, or before the shell has run once. This is the one place the
  # declared palette has a say on the Hyprland side, and only as a cold
  # start: noctalia overwrites it the first time it applies a theme.
  #
  # The keys match the template's one for one. hyprlock.nix only
  # actually reads five of them ($foreground, $primary, $secondary,
  # $tertiary, $error); the rest carry over from the colors.json era and
  # are kept so the two sources stay interchangeable.
  fallback = {
    background = p.bg;
    foreground = p.fg;
    primary = r.accent;
    secondary = r.success; # capslock indicator
    tertiary = p.brightCyan; # "checking password" indicator
    error = r.error;
    outline = r.muted;
    surface_variant = r.surfaceAlt;
    shadow = p.black;
  };

  # hyprlang wants bare hex for rgb(): `rgb(e6b450)`, no leading '#'.
  # Written out as a store file rather than inlined into the script: it
  # keeps a literal '$' out of the shell quoting entirely, and the
  # fallback stays readable as the hyprlang it is.
  fallbackFile = pkgs.writeText "hyprlock-colors-fallback.conf" (
    lib.concatStrings (
      lib.mapAttrsToList (k: v: "$" + k + " = " + config.my.theme.lib.noHash v + "\n") fallback
    )
  );

  generator = pkgs.writeShellApplication {
    name = "hyprlock-colors";
    text = ''
      # Seed hyprlock's color variables so `source` cannot fail on a host
      # where noctalia has not rendered them yet. A file that already
      # exists is noctalia's, and is left exactly as it is.
      out=${lib.escapeShellArg out}

      if [ -s "$out" ]; then
        exit 0
      fi

      mkdir -p "$(dirname "$out")"

      # Atomically, so a lock racing this never reads a half-written file.
      tmp=$(mktemp "$out.XXXXXX")
      trap 'rm -f "$tmp"' EXIT
      cp ${fallbackFile} "$tmp"
      chmod 644 "$tmp"
      mv "$tmp" "$out"
      trap - EXIT
    '';
  };
in
{
  options.my.hyprlock-colors = {
    file = mkOption {
      type = types.str;
      readOnly = true;
      default = out;
      description = ''
        The hyprlang color file. hyprlock.nix sources this, noctalia
        renders it from `template` on every theme apply, and hypridle.nix
        makes sure it at least exists before locking.
      '';
    };

    template = mkOption {
      type = types.path;
      readOnly = true;
      default = template;
      description = ''
        The noctalia template rendered into `file`. Consumed by
        noctalia.nix, which declares the template entry.
      '';
    };

    package = mkOption {
      type = types.package;
      readOnly = true;
      default = generator;
      description = ''
        The cold-start seeder, also on PATH as `hyprlock-colors`. A no-op
        once noctalia has rendered `file`.
      '';
    };
  };

  config = {
    home.packages = [ generator ];

    # So the file exists before the first lock of a fresh session, rather
    # than only after hypridle has fired once.
    home.activation.hyprlockColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${generator}/bin/hyprlock-colors
    '';
  };
}
