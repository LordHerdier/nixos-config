# home/modules/nvf/default.nix

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.my.nvim;

  # What 10-theme.nix feeds nightfox, as a Lua chunk: also the fragment
  # neovim re-reads when the runtime palette changes.
  paletteLua =
    t:
    let
      p = t.palette;
      pair = base: bright: "{ base = \"${p.${base}}\", bright = \"${p.${bright}}\" }";
    in
    ''
      return {
        palette = {
          black = "${p.black}",
          red = ${pair "red" "brightRed"},
          green = ${pair "green" "brightGreen"},
          yellow = ${pair "yellow" "brightYellow"},
          blue = ${pair "blue" "brightBlue"},
          magenta = ${pair "magenta" "brightMagenta"},
          cyan = ${pair "cyan" "brightCyan"},
          white = ${pair "white" "brightWhite"},
          bg0 = "${p.bg}",
          fg1 = "${p.fg}",
        },
        border = "${t.roles.border}",
      }
    '';

  follows = config.my.theme.follows cfg.palette;

  nvfConfig = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;

    # nvf runs its own evalModules, so home-manager's `config` is not in
    # scope inside the files below. The resolved theme has to be handed
    # across the boundary explicitly.
    extraSpecialArgs = {
      theme = config.my.theme.palettes.${cfg.palette};
      # Null when pinned: neovim then keeps the palette it was built with.
      themeRuntime = if follows then "${config.xdg.stateHome}/theme" else null;
      inherit paletteLua;
    };

    modules = [
      ./00-options.nix
      ./10-theme.nix
      ./20-lsp.nix
      ./90-keymaps.nix
      ./plugins
    ];
  };
in
{
  options.my.nvim = {
    palette = mkOption {
      type = types.enum (lib.attrNames config.my.theme.palettes);
      default = config.my.theme.default;
      defaultText = "config.my.theme.default";
      description = ''
        Which my.theme palette neovim draws its colors from. Follows the
        system palette; set it to pin neovim to a different one.
      '';
    };
  };

  config.my.theme.fragments.nvim = lib.mkIf follows {
    file = "nvim.lua";
    render = paletteLua;
    # No reload hook: every running neovim watches the state directory
    # (see 10-theme.nix) and re-applies on its own.
  };

  config.home.packages = [
    (pkgs.writeShellScriptBin "nvim" ''
      exec ${nvfConfig.neovim}/bin/nvim "$@"
    '')
  ];
}
