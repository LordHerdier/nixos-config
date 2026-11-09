# home/modules/kid/steam.nix
#
# The same wrapped Steam as the desktop profiles (its extraPkgs are
# runtime libs).
#
# Her library is /mnt/games/kiddo (modules/features/games-mount.nix);
# Charlotte's steamapps stays read-only to her.
#
# By hand, once: sign her in to her own Steam account, and turn on Family
# View (Steam → Settings → Family) with a PIN.

{ ... }:

{
  imports = [ ../steam.nix ];
}
