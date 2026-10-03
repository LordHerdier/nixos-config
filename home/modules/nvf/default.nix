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

  nvfConfig = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;

    # nvf runs its own evalModules, so home-manager's `config` is not in
    # scope inside the files below. The resolved theme has to be handed
    # across the boundary explicitly.
    extraSpecialArgs = {
      theme = config.my.theme.palettes.${cfg.palette};
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
      # Pinned rather than following my.theme.default: neovim, kitty and
      # tmux are each on a different palette today, and this keeps that
      # true while the colors move into tokens. Set it to
      # `config.my.theme.default` to fold neovim into the system palette.
      default = "gruvbox-nightfox";
      description = "Which my.theme palette neovim draws its colors from.";
    };
  };

  config.home.packages = [
    (pkgs.writeShellScriptBin "nvim" ''
      exec ${nvfConfig.neovim}/bin/nvim "$@"
    '')
  ];
}
