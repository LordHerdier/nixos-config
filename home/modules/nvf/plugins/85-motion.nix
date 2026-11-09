# home/modules/nvf/plugins/85-motion.nix
#
# Jump-to-anywhere motions.
#
# leap rather than flash-nvim: flash wants bare `s`/`S`, already taken by
# mini.surround (35-mini-surround.nix) and Save (../90-keymaps.nix). nvf
# binds leap under <leader>s* instead.

{ ... }:

{
  config.vim.utility.motion.leap = {
    enable = true;
    # Defaults:
    #   <leader>ss / <leader>sS  leap forward / backward to
    #   <leader>sx / <leader>sX  leap forward / backward till
    #   gs                       leap to another window
  };
}
