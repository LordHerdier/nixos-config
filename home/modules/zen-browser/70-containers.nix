# home/modules/zen-browser/70-containers.nix
#
# Contextual identities -- separate cookie jars for work/personal/etc.
# Stored in zen-sessions.jsonlz4, so close Zen before a switch once
# anything here is declared.
#
# `containersForce = true` deletes containers that are not declared
# here; leave it false to keep ones created by hand.
#
# A container id can be referenced from a space (spaces.<name>.container
# in 80-spaces.nix) to make that space open tabs in it.
{ ... }:

{
  programs.zen-browser.profiles.default = {
    # containersForce = true;
    # containers = {
    #   Personal = {
    #     id = 1;
    #     color = "purple";
    #     icon = "fingerprint";
    #   };
    #   Work = {
    #     id = 2;
    #     color = "blue";
    #     icon = "briefcase";
    #   };
    # };
  };
}
