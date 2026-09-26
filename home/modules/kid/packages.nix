# home/modules/kid/packages.nix
#
# Her whole userland. Short on purpose: malcontent only gates Flatpak,
# so this list — not parental controls — is what actually bounds what
# she can run.

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Educational activity suite aimed squarely at 2-10 year olds:
    # letters, counting, colours, simple logic puzzles.
    gcompris

    # Drawing, with stamps and sound effects. The one app she'll
    # probably open most.
    tuxpaint

    # Plain, obvious video player for anything on disk.
    celluloid

    # Image viewer (GNOME's, matches the rest of the session).
    loupe
  ];
}
