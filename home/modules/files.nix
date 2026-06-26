# home/modules/files.nix

{ dotfiles, ... }:

{
  home.file = {
    "bin" = {
      source = "${dotfiles}/bin/bin";
      recursive = true;
    };

    ".oh-my-posh" = {
      source = "${dotfiles}/omp/.oh-my-posh";
      recursive = true;
    };

    ".config/yazi" = {
      source = "${dotfiles}/yazi/.config/yazi";
      recursive = true;
    };

    ".config/concord/keymap.toml".text = ''
      # keymap.toml -- Concord, Colemak layout
      # Only non-default values are specified here.
      #
      # Colemak translation:
      #   e = down  (was j)    u = up    (was k)
      #   n = left  (was h)    i = right (was l)
      #   k = compose          (was i; mirrors nvf k -> insert mode)
      #   E = half-page down   U = half-page up  (mirrors nvf 5j/5k)
      #   N = scroll-horiz L   I = scroll-horiz R

      [keymap]
      # -- Navigation --
      SelectNext = "e"
      SelectPrevious = "u"
      CycleFocusNext = { keys = ["tab", "i", "right"] }
      CycleFocusPrevious = { keys = ["<S-tab>", "n", "left"] }
      HalfPageDown = { keys = ["<C-d>", "E"] }
      HalfPageUp = { keys = ["<C-u>", "U"] }
      ScrollHorizontalLeft = "N"
      ScrollHorizontalRight = "I"
      ResizePaneLeft = { keys = ["<A-n>", "<A-left>"] }
      ResizePaneRight = { keys = ["<A-i>", "<A-right>"] }
      ToggleGuildPane = { keys = ["<leader>1", "<leader>e"] }

      # -- Actions --
      StartComposer = "k"
      EditMessage = "a"

      [keymap.groups]
      "<leader>v" = "Voice"

      [keymap.guild_actions]
      MuteServer = { keys = ["x"], description = "mute server" }

      [keymap.channel_actions]
      MuteChannel = { keys = ["x"], description = "mute channel" }

      [keymap.message_actions]
      EditMessage = "a"
      ShowReactionUsers = "z"

      [keymap.composer]
      OpenEditor = "<C-o>"
    '';

  };
}
