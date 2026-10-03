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
      default = config.my.theme.default;
      defaultText = "config.my.theme.default";
      description = ''
        Which my.theme palette neovim draws its colors from. Follows the
        system palette; set it to pin neovim to a different one.
      '';
    };
  };

  config.home.packages = [
    (pkgs.writeShellScriptBin "nvim" ''
      exec ${nvfConfig.neovim}/bin/nvim "$@"
    '')
  ];
}
