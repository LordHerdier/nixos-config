# home/modules/theme/runtime.nix
#
# Switching `my.theme` palettes without a rebuild.
#
# An app that wants to follow the runtime palette registers a *fragment*
# under `my.theme.fragments.<app>`: a function from a resolved theme to the
# text of the colour file that app reads. Every fragment is rendered for
# every palette at build time, so the colours still come from one place and
# there is nothing to keep in sync by hand:
#
#   ~/.config/theme/palettes/<palette>/<app>.<ext>     (store, read-only)
#   ~/.local/state/theme/active -> ../../../.config/theme/palettes/<palette>
#
# The app's generated config includes `~/.local/state/theme/active/<app>.<ext>`
# and `theme-set` repoints `active`, then runs each fragment's `reload` to
# make the running app re-read it. `theme-set default` drops the override and
# points `active` back at `my.theme.default`; a rebuild does the same when
# there is no override (see the activation script), so changing the default
# in Nix still recolours a live session.
#
# PINS. An app that pins itself to a palette other than `my.theme.default`
# (my.kitty.palette = ...) does not register a fragment and keeps its colours
# inline, so it stays put. `follows` is the test for that.
#
# | Option                       | Purpose                                      |
# | ---------------------------- | -------------------------------------------- |
# | `my.theme.fragments.<app>`   | Per-app colour file renderer and reload hook |
# | `my.theme.follows`           | Does a given palette name track the default  |
# | `my.theme.runtime.active`    | Path apps include their fragment from        |

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    attrNames
    concatMapStringsSep
    concatStringsSep
    mapAttrsToList
    mkOption
    types
    ;

  cfg = config.my.theme;
  stateDir = "${config.xdg.stateHome}/theme";
  paletteDir = "${config.xdg.configHome}/theme/palettes";

  fragmentType = types.submodule {
    options = {
      file = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "kitty.conf";
        description = ''
          File name inside each palette's directory. Null for a hook that
          only reloads something that gets its colours another way.
        '';
      };

      render = mkOption {
        type = types.functionTo types.str;
        default = _: "";
        description = "Resolved theme -> the contents of the file.";
      };

      reload = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Shell run after the active palette changes, to make the running
          app re-read its fragment. Runs under `|| true` with nounset off,
          so an app that is not running is not an error. $THEME_NAME is
          the palette name, or empty for the Nix default.
        '';
      };

      runtimeInputs = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Packages `reload` needs on PATH.";
      };
    };
  };

  fragments = lib.attrValues cfg.fragments;

  # One directory per palette holding every registered fragment.
  palettes = pkgs.linkFarm "theme-palettes" (
    mapAttrsToList (name: theme: {
      inherit name;
      path = pkgs.linkFarm "theme-${name}" (
        map (f: {
          name = f.file;
          path = pkgs.writeText "theme-${name}-${f.file}" (f.render theme);
        }) (lib.filter (f: f.file != null) fragments)
      );
    }) cfg.palettes
  );

  themeSet = pkgs.writeShellApplication {
    name = "theme-set";
    runtimeInputs = [
      pkgs.coreutils
    ]
    ++ lib.concatMap (f: f.runtimeInputs) fragments;
    runtimeEnv = {
      THEME_PALETTES = "${paletteDir}";
      THEME_STATE = stateDir;
      THEME_DEFAULT = cfg.default;
      THEME_NAMES = concatStringsSep "\n" (attrNames cfg.palettes);
    };
    text = ''
      ${builtins.readFile ./theme-set.sh}
      reload_all() {
        export THEME_NAME=''${1:-}
        ${concatMapStringsSep "\n" (f: ''
          (
            set +u
            ${f.reload}
          ) || true
        '') fragments}
      }
      main "$@"
    '';
  };
in
{
  options.my.theme = {
    fragments = mkOption {
      type = types.attrsOf fragmentType;
      default = { };
      description = "Colour files rendered per palette; see the header.";
    };

    follows = mkOption {
      type = types.functionTo types.bool;
      readOnly = true;
      default = name: name == cfg.default;
      description = ''
        True when an app on palette `name` should read the runtime palette.
        An app pinned to anything else keeps its colours inline.
      '';
    };

    runtime.active = mkOption {
      type = types.str;
      readOnly = true;
      default = "${stateDir}/active";
      description = "Directory holding the active palette's fragments.";
    };
  };

  config = lib.mkIf (cfg.fragments != { }) {
    xdg.configFile."theme/palettes".source = palettes;

    home.packages = [ themeSet ];

    # No override: `active` tracks my.theme.default, so a rebuild that
    # changes it recolours. With one, leave it alone (the palettes dir it
    # points through is updated in place by the generation switch).
    home.activation.themeActive = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run mkdir -p ${stateDir}
      if [ ! -e ${stateDir}/override ]; then
        run ln -sfn ${paletteDir}/${cfg.default} ${stateDir}/active
      elif [ ! -e ${stateDir}/active ]; then
        run ln -sfn ${paletteDir}/"$(cat ${stateDir}/override)" ${stateDir}/active
      fi
      run ${lib.getExe themeSet} reload || true
    '';
  };
}
