# home/modules/nvf/plugins/15-yanky.nix
{ ... }:
{
  config.vim = {
    utility.yanky-nvim.enable = true;
    utility.yanky-nvim.setupOpts.ring.storage = "sqlite";

    keymaps = [
      # ==================== Yanky ====================
      {
        mode = "n";
        key = "p";
        action = "<Plug>(YankyPutAfter)";
        desc = "Yanky Put After";
      }
      {
        mode = "x";
        key = "p";
        action = "<Plug>(YankyPutAfter)";
        desc = "Yanky Put After";
      }
      {
        mode = "n";
        key = "P";
        action = "<Plug>(YankyPutBefore)";
        desc = "Yanky Put Before";
      }
      {
        mode = "x";
        key = "P";
        action = "<Plug>(YankyPutBefore)";
        desc = "Yanky Put Before";
      }

      {
        mode = "n";
        key = "gp";
        action = "<Plug>(YankyGPutAfter)";
        desc = "Yanky GPut After";
      }
      {
        mode = "x";
        key = "gp";
        action = "<Plug>(YankyGPutAfter)";
        desc = "Yanky GPut After";
      }
      {
        mode = "n";
        key = "gP";
        action = "<Plug>(YankyGPutBefore)";
        desc = "Yanky GPut Before";
      }
      {
        mode = "x";
        key = "gP";
        action = "<Plug>(YankyGPutBefore)";
        desc = "Yanky GPut Before";
      }
      {
        mode = "n";
        key = "<c-p>";
        action = "<Plug>(YankyPreviousEntry)";
        desc = "Yanky Previous Entry";
      }
      {
        mode = "n";
        key = "<c-n>";
        action = "<Plug>(YankyNextEntry)";
        desc = "Yanky Next Entry";
      }
    ];
  };
}
