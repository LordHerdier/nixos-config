# home/modules/nvf/plugins/85-motion.nix
#
# Jump-to-anywhere motions.
#
# leap rather than flash-nvim: flash wants bare `s`/`S`, which are already
# mini.surround's prefix (35-mini-surround.nix) and Save (90-keymaps.nix).
# nvf binds leap under <leader>s* instead, so it slots in next to the
# grug-far <leader>sr mapping without touching the colemak home row.

{ ... }:

{
  config.vim.utility.motion.leap = {
    enable = true;
    # Defaults, all collision-free here:
    #   <leader>ss / <leader>sS  leap forward / backward to
    #   <leader>sx / <leader>sX  leap forward / backward till
    #   gs                       leap to another window
  };
}
