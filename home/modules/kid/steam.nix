# home/modules/kid/steam.nix
#
# Reuses the same wrapped Steam as Charlotte's session — the extraPkgs
# list there is about runtime libs, not about who's logged in.
#
# Her library lives at /mnt/games/kiddo (created by
# modules/features/games-mount.nix). /mnt/games is 0775 charlotte:users
# and her primary group is "users", so she can create and write there,
# while Charlotte's own steamapps subtree stays 0755-owned and read-only
# to her.
#
# Two things to do by hand once, that config can't express: sign her in
# to her own Steam account, and turn on Family View (Steam → Settings →
# Family) with a PIN so the store and your library aren't one click away.

{ ... }:

{
  imports = [ ../steam.nix ];
}
