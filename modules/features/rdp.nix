# modules/features/rdp.nix
#
# GNOME's built-in RDP server (gnome-remote-desktop), for connecting from
# an iPad/other devices as a general-purpose workstation session rather
# than over Sunshine/Moonlight (which is tuned for game streaming, not
# productivity — no clipboard/file niceties, couch-controller-oriented).
#
# Using headless mode (grdctl --headless), not the default screen-sharing
# mode: default mode mirrors/controls the live autologin session, which is
# the same one Sunshine streams to the TV — an RDP session and an active
# Moonlight stream would fight over the same cursor and the same display
# mode apthos-display-sync manages. Headless mode spins up its own virtual
# session on demand instead, fully decoupled from whatever's happening on
# the TV.
#
# gnome-remote-desktop ships this as a *user*-session unit
# (gnome-remote-desktop-headless.service, share/systemd/user/ in the
# package — visible to systemd --user automatically since the package
# lands in /run/current-system/sw). Its [Install] section says
# WantedBy=gnome-session.target, but same as the system unit, NixOS
# doesn't act on a package's [Install] section by itself — nothing ever
# creates the enabling symlink unless it's wired up here, so the daemon
# would otherwise never start even though `grdctl` could still configure
# it.
#
# Still doesn't turn RDP on by itself: the backend starts disabled with no
# credentials until someone runs, once, logged into the GNOME session
# (e.g. via the Proxmox console or Sunshine):
#
#   grdctl --headless rdp set-credentials <username> <password>
#   grdctl --headless rdp enable

{ ... }:

{
  services.gnome.gnome-remote-desktop.enable = true;

  systemd.user.services.gnome-remote-desktop-headless.wantedBy = [ "gnome-session.target" ];

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
