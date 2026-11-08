# home/modules/hyprland/hyprlock-colors.nix
#
# Bridges noctalia's runtime colors into hyprlock, which can't read
# noctalia's theme. noctalia renders noctalia-colors.conf.tmpl into
# `file` on every theme apply, startup included; the template entry is
# declared in noctalia.nix, this module owns the template and the path.
#
# The generator covers one case: a host where noctalia has never run.
# hyprlock treats a missing `source`d file as fatal, so it seeds the file
# from `my.theme` and never overwrites one noctalia has rendered. No
# inotify watch needed: hyprlock only reads the file at launch.

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

  # Keys match the template one for one. hyprlock.nix only reads five
  # ($foreground, $primary, $secondary, $tertiary, $error); the rest are
  # kept so the two sources stay interchangeable.
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

  # hyprlang's rgb() wants bare hex. A store file rather than inline in
  # the script keeps the literal '$' out of shell quoting.
  fallbackFile = pkgs.writeText "hyprlock-colors-fallback.conf" (
    lib.concatStrings (
      lib.mapAttrsToList (k: v: "$" + k + " = " + config.my.theme.lib.noHash v + "\n") fallback
    )
  );

  generator = pkgs.writeShellApplication {
    name = "hyprlock-colors";
    text = ''
      # An existing file is noctalia's; leave it alone.
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

    # So the file exists before the first lock, not only once hypridle
    # has fired.
    home.activation.hyprlockColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${generator}/bin/hyprlock-colors
    '';
  };
}
