# home/modules/nvf/plugins/55-dap.nix
#
# Debugging. Adapters and launch configurations come from
# `vim.languages.enableDAP` in ../20-lsp.nix; this only enables nvim-dap
# and its UI.
#
# nvf's default mappings:
#   <leader>dc  continue / start      <leader>db  toggle breakpoint
#   <leader>dR  restart               <leader>dq  terminate
#   <leader>du  toggle dap-ui         <leader>dr  toggle REPL
#   <leader>dh  hover value           <leader>d.  re-run last session
#   <leader>dgi step into             <leader>dgo step out
#   <leader>dgj step over             <leader>dgk step back
#   <leader>dgc run to cursor
#   <leader>dvo / <leader>dvi  up / down the stacktrace

{ ... }:

{
  config.vim.debugger.nvim-dap = {
    enable = true;

    ui = {
      enable = true;
      # Open the panels on session start, close them on exit.
      autoStart = true;
    };
  };
}
