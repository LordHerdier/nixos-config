# home/modules/git.nix

{
  programs.git = {
    enable = true;
    userName = "Charlotte Whittleman";
    userEmail = "brennwh@siue.edu";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}

