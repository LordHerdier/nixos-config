# home/modules/nvf/plugins/25-alpha.nix

{ ... }:

{
  config.vim = {
    dashboard.alpha = {
      enable = true;
    };

    # Custom header + buttons.
    # nvf lazy-loads alpha-nvim (event = VimEnter / cmd), and it calls
    # alpha.setup() itself using the "dashboard" theme. A top-level
    # luaConfigRC runs at startup, before alpha is ever loaded, so
    # `require("alpha")` there fails. Instead, hook into beforeSetup,
    # which nvf runs after the plugin loads but before it calls setup().
    lazy.plugins.alpha-nvim.beforeSetup = # lua
      ''
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
          "                                   ",
          "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆        ",
          "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦      ",
          "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄    ",
          "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄   ",
          "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀  ",
          "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠂  ⠤⢀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄ ",
          "  ⣿⣿⠁⣿⣿⣿⡄ ⣿⣿⡁    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣿⣿⡏",
          "   ⢸⣿⣿⢸⣿⣿⡁⢸⣿⣿⣧   ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢿⠿⣿⣿⣿",
          "    ⣿⣿⣿⣿⣿⣧⣿⣿⣿⣿⠇⠄  ⢸⣿⣿⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⡟",
          "     ⠙⣿⣿⢿⣿⣿⠿⠃   ⠄⣿⣿⣿⡿⣿⣿⣿⣿⣿⡇⣿⣿⣿⡇",
          "       ⠈⠉⠁     ⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢸⣿⣿⣿⠇",
          "                ⣿⣿⣿⣿⣿⡿⠛⣿⣿⣿⠟  ⠘⣿⡇ ",
          "                ⠛⣿⣿⣿⣿  ⣿⣿⣿⣿⡀  ⠈  ",
          "                  ⠈⠛⠉  ⠉⣿⣿⣿⣿⣿⣶⣤  ",
          "                       ⠉⠛⠉⠉⠛⠉  ",
          "",
          "                  N V F",
          "",
        }

        dashboard.section.buttons.val = {
          dashboard.button("f", "  Find file",       ":Telescope find_files<CR>"),
          dashboard.button("g", "  Live grep",       ":Telescope live_grep<CR>"),
          dashboard.button("r", "  Recent files",    ":Telescope oldfiles<CR>"),
          dashboard.button("q", "  Quit",            ":qa<CR>"),
        }

        dashboard.section.footer.val = ""
        dashboard.config.layout[1].val = 3
      '';
  };
}
