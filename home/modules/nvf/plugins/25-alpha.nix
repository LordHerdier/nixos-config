# home/modules/nvf/plugins/25-alpha.nix

{ ... }:

{
  config.vim = {
    dashboard.alpha = {
      enable = true;
    };

    # Custom header + buttons via luaConfigRC
    # alpha is loaded by nvf, so we just override the config
    luaConfigRC.alpha-custom = # lua
      ''
        local alpha = require("alpha")
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

        alpha.setup(dashboard.config)
      '';
  };
}
