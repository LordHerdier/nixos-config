# home/modules/git.nix

{
  programs.git = {
    enable = true;
    settings = {
      user.email = "charlotte@whittleman.net";
      user.name = "Charlotte Whittleman";
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      core.hooksPath = ".githooks";
    };
  };
}
