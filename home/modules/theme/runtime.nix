# home/modules/theme/runtime.nix
#
# Switching `my.theme` palettes without a rebuild.
#
# An app that follows the runtime palette registers a *fragment* under
# `my.theme.fragments.<app>`: a function from a resolved theme to the text
# of its colour file. Every fragment is rendered for every palette at build
# time:
#
#   ~/.config/theme/palettes/<palette>/<app>.<ext>     (store, read-only)
#   ~/.local/state/theme/active -> ~/.config/theme/palettes/<palette>
#                                  (or ~/.local/state/theme/wal-palette)
#
# The app's config includes `~/.local/state/theme/active/<app>.<ext>`;
# `theme-set` repoints `active` and runs each fragment's `reload`. With no
# override set, activation points `active` back at `my.theme.default`, so
# changing the default in Nix still recolours a live session.
#
# An app pinned to a palette other than the default (my.kitty.palette =
# ...) registers no fragment and keeps its colours inline; `follows` is
# the test for that.

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

      wal = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Also follow `theme-set wal`. The fragment is rendered once with
          placeholder colours, and wal's real ones are substituted in at
          runtime, so `render` must only pass palette and role colours
          through (no maths on them beyond what mkTheme derives) and must
          not use `accentDim`. Fragments that do not opt in keep the
          default palette's colours while wal is active.
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

  # nixpkgs passes the wrapper args as one "--prefix PATH : ..." string,
  # which the current makeWrapper hook rejects. Split into separate words.
  pywal = pkgs.pywal16.overrideAttrs (_: {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [ pkgs.imagemagick ])
    ];
  });

  # Placeholder palette for `wal = true` fragments: one distinct, valid hex
  # per slot (so mkTheme's role derivation still works), each mapped to the
  # wal colour that replaces it at runtime.
  walSlots =
    let
      keys = cfg.lib.paletteKeys;
      slot =
        k:
        if k == "bg" then
          "background"
        else if k == "fg" then
          "foreground"
        else
          "color${toString (lib.lists.findFirstIndex (x: x == k) null ansiOrder)}";
      ansiOrder = lib.filter (k: k != "bg" && k != "fg") keys;
    in
    lib.imap0 (i: k: {
      inherit k;
      hex = "c0de${cfg.lib.hexByte i}";
      slot = slot k;
    }) keys;

  walTheme = cfg.lib.mkTheme {
    name = "wal";
    palette = lib.listToAttrs (map (s: lib.nameValuePair s.k "#${s.hex}") walSlots);
  };

  walTemplates = pkgs.linkFarm "theme-wal-templates" (
    map (f: {
      name = f.file;
      path = pkgs.writeText "theme-wal-${f.file}" (f.render walTheme);
    }) (lib.filter (f: f.wal && f.file != null) fragments)
  );

  themeSet = pkgs.writeShellApplication {
    name = "theme-set";
    runtimeInputs = [
      pkgs.coreutils
      pywal
      pkgs.gnused
      pkgs.jq
    ]
    ++ lib.concatMap (f: f.runtimeInputs) fragments;
    runtimeEnv = {
      THEME_PALETTES = "${paletteDir}";
      THEME_STATE = stateDir;
      THEME_DEFAULT = cfg.default;
      THEME_WAL_TEMPLATES = "${walTemplates}";
      THEME_WAL_SLOTS = concatMapStringsSep "\n" (s: "${s.hex} ${s.slot}") walSlots;
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

    # No override: `active` tracks my.theme.default. With one, leave it
    # alone; the palettes dir it points through updates with the generation.
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
