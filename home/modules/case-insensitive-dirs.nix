# home/modules/case-insensitive-dirs.nix
#
# Some machines have ~/documents, others ~/Documents (and similar
# case-differing dirs). Tools like tmuxinator take a literal `root:` path
# with no case-insensitive matching, so reconcile each pair into a symlink
# here: whichever spelling exists as a real dir "wins", and the other
# spelling becomes a symlink to it. If both exist as real dirs already,
# leave them alone and warn so they can be merged by hand.
{ lib, ... }:
{
  home.activation.reconcileCaseDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    reconcile_case_dir() {
      local a="$HOME/$1" b="$HOME/$2"
      if [ -e "$a" ] && [ ! -L "$a" ] && [ -e "$b" ] && [ ! -L "$b" ]; then
        echo "Warning: both $a and $b exist; not touching them, merge manually." >&2
      elif [ -e "$a" ] && [ ! -e "$b" ]; then
        $DRY_RUN_CMD ln -s "$a" "$b"
      elif [ -e "$b" ] && [ ! -e "$a" ]; then
        $DRY_RUN_CMD ln -s "$b" "$a"
      fi
    }
    reconcile_case_dir documents Documents
  '';
}
