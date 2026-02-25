# home/modules/git.nix

{
  programs.git = {
    enable = true;
    settings = {
      user.email = "brennwh@siue.edu";
      user.name = "Charlotte Whittleman";
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}
