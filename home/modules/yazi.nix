# home/modules/yazi.nix
#
# yazi colours from `my.theme`. theme.toml is a runtime fragment (pywal
# included): ~/.config/yazi/theme.toml links to the active palette's copy.
#
# yazi reads theme.toml once at startup and has no reload hook, so a
# running yazi keeps its old colours until restarted. Anything started
# after `theme-set` picks up the new palette.
#
# yazi.toml and keymap.toml still come from the dotfiles repo (files.nix).

{ config, lib, ... }:

let
  # No TOML generator in lib, and pkgs.formats needs a build (IFD here).
  # Inline tables on one line per top-level key are valid TOML.
  toml =
    v:
    if lib.isAttrs v then
      "{ "
      + lib.concatStringsSep ", " (lib.mapAttrsToList (k: x: "${builtins.toJSON k} = ${toml x}") v)
      + " }"
    else if lib.isList v then
      "[" + lib.concatMapStringsSep ", " toml v + "]"
    else
      builtins.toJSON v;

  toDocument =
    attrs: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} = ${toml v}") attrs) + "\n";

  cfg = config.my.yazi;
  follows = config.my.theme.follows cfg.palette;

  # Must stay wal-safe (see the `wal` fragment option): palette and role
  # colours passed straight through, and no accentDim.
  render =
    t:
    let
      p = t.palette;
      r = t.roles;
      fg = color: { fg = color; };
      sel = {
        fg = r.selectionFg;
        bg = r.selectionBg;
      };
      mode = main: {
        fg = r.accentFg;
        bg = main;
        bold = true;
      };
      edge = color: {
        fg = color;
        bg = r.surface;
      };
    in
    toDocument {
      mgr = {
        cwd = {
          fg = p.cyan;
          bold = true;
        };
        hovered = sel // {
          bold = true;
        };
        preview_hovered = {
          underline = true;
        };
        find_keyword = {
          fg = p.yellow;
          bold = true;
          italic = true;
        };
        find_position = {
          fg = p.magenta;
          bg = "reset";
          bold = true;
          italic = true;
        };
        marker_copied = {
          fg = p.green;
          bg = p.green;
        };
        marker_cut = {
          fg = p.red;
          bg = p.red;
        };
        marker_marked = {
          fg = p.cyan;
          bg = p.cyan;
        };
        marker_selected = {
          fg = p.yellow;
          bg = p.yellow;
        };
        count_copied = {
          fg = r.accentFg;
          bg = p.green;
        };
        count_cut = {
          fg = r.accentFg;
          bg = p.red;
        };
        count_selected = {
          fg = r.accentFg;
          bg = p.yellow;
        };
        border_style = fg r.borderInactive;
      };

      tabs = {
        active = {
          fg = r.accentFg;
          bg = r.accent;
          bold = true;
        };
        inactive = {
          fg = p.fg;
          bg = r.surface;
        };
      };

      mode = {
        normal_main = mode p.blue;
        normal_alt = edge p.blue;
        select_main = mode p.red;
        select_alt = edge p.red;
        unset_main = mode p.magenta;
        unset_alt = edge p.magenta;
      };

      status = {
        overall = { };
        sep_left = {
          open = "";
          close = "";
        };
        sep_right = {
          open = "";
          close = "";
        };
        perm_type = fg p.green;
        perm_read = fg p.yellow;
        perm_write = fg p.red;
        perm_exec = fg p.cyan;
        perm_sep = fg r.muted;
        progress_label = {
          fg = p.fg;
          bold = true;
        };
        progress_normal = {
          fg = r.accent;
          bg = r.surface;
        };
        progress_error = {
          fg = r.error;
          bg = r.surface;
        };
      };

      which = {
        cols = 3;
        mask = {
          bg = r.surface;
        };
        cand = fg p.cyan;
        rest = fg r.muted;
        desc = fg p.magenta;
        separator = "  ";
        separator_style = fg r.muted;
      };

      confirm = {
        border = fg r.border;
        title = fg r.accent;
        content = { };
        list = { };
        btn_yes = sel;
        btn_no = { };
        btn_labels = [
          "  [Y]es  "
          "  (N)o  "
        ];
      };

      spot = {
        border = fg r.border;
        title = fg r.accent;
        tbl_col = fg r.border;
        tbl_cell = {
          fg = r.accent;
          reversed = true;
        };
      };

      notify = {
        title_info = fg p.green;
        title_warn = fg r.warning;
        title_error = fg r.error;
      };

      pick = {
        border = fg r.border;
        active = {
          fg = p.magenta;
          bold = true;
        };
        inactive = { };
      };

      input = {
        border = fg r.border;
        title = { };
        value = { };
        selected = {
          reversed = true;
        };
      };

      cmp = {
        border = fg r.border;
        active = {
          fg = r.accentFg;
          bg = r.accent;
        };
        inactive = { };
      };

      tasks = {
        border = fg r.border;
        title = { };
        hovered = {
          fg = p.magenta;
          underline = true;
        };
      };

      help = {
        on = fg p.magenta;
        run = fg p.cyan;
        desc = fg r.muted;
        hovered = sel // {
          bold = true;
        };
        footer = {
          fg = p.fg;
          bg = r.surface;
        };
      };

      filetype.rules = [
        {
          mime = "image/*";
          fg = p.yellow;
        }
        {
          mime = "{audio,video}/*";
          fg = p.magenta;
        }
        {
          mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
          fg = p.red;
        }
        {
          mime = "application/{pkcs*,pgp-keys,pgp-signature,x509-ca-cert,vnd.ms-fontobject}";
          fg = p.cyan;
        }
        {
          mime = "application/{debian*-package,redhat-package-manager,rpm,android.package-archive}";
          fg = p.cyan;
        }
        {
          url = "*";
          is = "orphan";
          bg = r.error;
          fg = r.accentFg;
        }
        {
          url = "*";
          is = "exec";
          fg = p.green;
        }
        {
          url = "*/";
          fg = p.blue;
        }
      ];
    };
in
{
  options.my.yazi.palette = lib.mkOption {
    type = lib.types.enum (lib.attrNames config.my.theme.palettes);
    default = config.my.theme.default;
    defaultText = "config.my.theme.default";
    description = ''
      Which my.theme palette yazi draws its colors from. Follows the system
      palette (and `theme-set`); set it to pin a different one.
    '';
  };

  # No reload hook: yazi only reads theme.toml at startup.
  config.my.theme.fragments.yazi = lib.mkIf follows {
    file = "yazi-theme.toml";
    wal = true;
    inherit render;
  };

  config.xdg.configFile."yazi/theme.toml" =
    if follows then
      {
        source = config.lib.file.mkOutOfStoreSymlink "${config.my.theme.runtime.active}/yazi-theme.toml";
      }
    else
      { text = render config.my.theme.palettes.${cfg.palette}; };
}
