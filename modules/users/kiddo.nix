# modules/users/kiddo.nix
#
# Little-sister account. Imported by Index only, not modules/common, so no
# other host grows this user.

{ pkgs, ... }:

{
  users.users.kiddo = {
    isNormalUser = true;
    description = "Kiddo";

    # No "wheel" (no sudo/rebuilds). "video" is for brightness keys. Not in
    # "networkmanager", so she can't reconfigure the network.
    extraGroups = [ "video" ];

    # Primary group "users" gets group write on /mnt/games (games-mount.nix).

    # bash, not zsh: home/modules/zsh is Charlotte's prompt/atuin/oh-my-posh
    # stack.
    shell = pkgs.bash;

    # Only applied at account creation, and world-readable in the store;
    # fine for a kid's local account only. `passwd kiddo` supersedes it.
    # initialPassword = "kiddo";
  };

  # Mahjongg, sudoku, Quadrapassel and friends.
  services.gnome.games.enable = true;

  # GNOME apps land in environment.systemPackages, so this prunes the whole
  # machine, not just her session: duplicates (Epiphany) and account-shaped
  # dead ends for a kid (Geary, Contacts, Connections, Tour).
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    gnome-contacts
    geary
    epiphany
  ];
}
