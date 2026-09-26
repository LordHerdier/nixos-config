# modules/users/kiddo.nix
#
# Little-sister account. Host-scoped on purpose — imported by Index only,
# not by modules/common/users.nix, so the WSL hosts don't grow a user that
# makes no sense there.

{ pkgs, ... }:

{
  users.users.kiddo = {
    isNormalUser = true;
    description = "Kiddo";

    # No "wheel": no sudo, no rebuilds, no nix-env. "video" is for
    # brightness keys. Deliberately not in "networkmanager" — she can see
    # the wifi status but can't reconfigure the network.
    extraGroups = [ "video" ];

    # Her primary group is "users" (the NixOS default), which is what the
    # /mnt/games tmpfiles rule grants group write to. See
    # modules/features/games-mount.nix.

    # bash, not zsh: home/modules/zsh is built around Charlotte's prompt,
    # atuin history and oh-my-posh, none of which belongs in her closure.
    shell = pkgs.bash;

    # Only applied when the account is first created, and it is readable
    # in the world-readable Nix store — fine for a kid's local account on
    # a machine you log her into, not fine for anything else. Change it
    # with `passwd kiddo` and this line stops mattering.
    # initialPassword = "kiddo";
  };
}
