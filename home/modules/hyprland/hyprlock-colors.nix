# home/modules/hyprland/hyprlock-colors.nix
#
# Bridges noctalia's runtime colors into hyprlock.
#
# On the Hyprland hosts the desktop's colors are noctalia's to decide --
# it derives them from the wallpaper and rewrites
# ~/.config/noctalia/colors.json every time the scheme changes. `my.theme`
# does not compete with that; see home/modules/theme/default.nix.
#
# hyprlock can't read that JSON, so this generates the hyprlang variable
# file it sources. What it replaces is a line pointing at
# ~/.config/Ax-Shell/config/hypr/colors.conf -- a leftover from the shell
# this config used before noctalia. That file is still on disk on hosts
# that ran Ax-Shell, so the lock screen wasn't visibly broken; it was
# quietly frozen on a palette from a shell that is no longer installed,
# and on a fresh host the source would simply fail.
#
# WHY NOT noctalia's own hyprland template. noctalia ships one, writing
# ~/.config/hypr/noctalia/noctalia-colors.conf, and it would be the
# obvious answer -- except it has to be switched on in noctalia's GUI
# (settings.json is GUI-owned after first activation, so we can't enable
# it declaratively), it defines no foreground color, and its
# postProcess step tries to edit ~/.config/hypr/hyprland.conf, which
# here is a read-only store symlink. Reading colors.json instead needs
# no GUI state and no cooperation: that file is always written.
#
# WHY NO inotify WATCH. hyprlock parses its config when it launches, so
# the file only has to be correct at that moment. Regenerating it in
# hypridle's lock_cmd (see hypridle.nix) is exact, where a systemd path
# unit would mean reasoning about whether noctalia replaces the file by
# rename -- which inotify reports differently -- for no benefit.

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

  noctaliaColors = "${config.xdg.configHome}/noctalia/colors.json";
  out = "${config.xdg.configHome}/hypr/noctalia-colors.conf";

  # Fallback, used only when noctalia has not written colors.json yet --
  # a fresh install, or before the shell has run once. This is the one
  # place the declared palette has a say on the Hyprland side, and only
  # as a cold start: the next lock after noctalia writes its file picks
  # up the runtime colors.
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
    runtimeInputs = [ pkgs.jq ];
    text = ''
      # Regenerate hyprlock's color variables from noctalia's current
      # scheme. Safe to run at any time; writes atomically so a lock
      # racing this never reads a half-written file.
      src=${lib.escapeShellArg noctaliaColors}
      out=${lib.escapeShellArg out}

      mkdir -p "$(dirname "$out")"
      tmp=$(mktemp "$out.XXXXXX")
      trap 'rm -f "$tmp"' EXIT

      # Every key has to be a string, or a partially-written colors.json
      # would yield `rgb(null)` and a lock screen that fails to parse.
      keys='["mSurface","mOnSurface","mPrimary","mSecondary","mTertiary","mError","mOutline","mSurfaceVariant","mShadow"]'

      # `. as $o` first: inside all(), `.` is the generated key name, not
      # the object, so has()/[] have to be applied to the bound object.
      if [ -r "$src" ] && jq -e --argjson k "$keys" \
           '. as $o | all($k[]; . as $n | ($o | has($n)) and ($o[$n] | type == "string"))' \
           "$src" >/dev/null 2>&1; then
        jq -r '
          def bare: sub("^#"; "");
          "$background = \(.mSurface | bare)",
          "$foreground = \(.mOnSurface | bare)",
          "$primary = \(.mPrimary | bare)",
          "$secondary = \(.mSecondary | bare)",
          "$tertiary = \(.mTertiary | bare)",
          "$error = \(.mError | bare)",
          "$outline = \(.mOutline | bare)",
          "$surface_variant = \(.mSurfaceVariant | bare)",
          "$shadow = \(.mShadow | bare)"
        ' "$src" > "$tmp"
      else
        cp ${fallbackFile} "$tmp"
      fi

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
        The generated hyprlang color file. hyprlock.nix sources this and
        hypridle.nix refreshes it before locking.
      '';
    };

    package = mkOption {
      type = types.package;
      readOnly = true;
      default = generator;
      description = "The generator, also on PATH as `hyprlock-colors`.";
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
