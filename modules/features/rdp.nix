# modules/features/rdp.nix
#
# GNOME's built-in RDP server (gnome-remote-desktop), for connecting from
# an iPad/other devices as a general-purpose workstation session rather
# than over Sunshine/Moonlight (which is tuned for game streaming, not
# productivity — no clipboard/file niceties, couch-controller-oriented).
#
# Runs in *system* mode (grdctl --system) — what GNOME's Settings panel
# calls "Remote Login". The two modes that came before it both lost to
# Sunshine:
#
#   * Default screen-sharing mode mirrors/controls the live autologin
#     session, which is the same one Sunshine streams to the TV. An RDP
#     session and an active Moonlight stream fight over the same cursor
#     and the same display mode apthos-display-sync manages.
#
#   * Headless mode (grdctl --headless) spins up its own virtual session,
#     so it doesn't fight over the *display* — but it still runs inside
#     Charlotte's user session, and gnome-remote-desktop-headless claims
#     Mutter's RemoteDesktop portal backend for itself the moment it's
#     running, even with no RDP client connected. Sunshine's startup needs
#     that same portal (to ask for keyboard/mouse injection) and just
#     hangs forever waiting for it if the headless service got there
#     first — Sunshine never finishes starting and never opens its
#     Moonlight ports. That forced rdp.nix to be manual/on-demand only:
#     start the unit before RDPing in, stop it to give Sunshine the portal
#     back.
#
# System mode sidesteps both. The daemon is a *system* service running as
# the unprivileged `gnome-remote-desktop` user, with no user session and
# no portal of its own. When a client authenticates it asks GDM for a new
# remote display (org.gnome.DisplayManager.RemoteDisplayFactory) and hands
# the socket to that brand-new session's handover service. Charlotte's
# autologin session — its Mutter, its portals, its Sunshine — is never
# touched, so this can be always-on instead of on-demand.
#
# That GDM call is also a hard dependency, not a nicety: there is no
# SDDM/greetd equivalent of RemoteDisplayFactory, and without it a client
# authenticates and then hangs at handover forever. Hence the assertion,
# and hence Apthos overriding desktop-common's SDDM with GDM.
#
# NixOS doesn't act on a package's [Install] section, so none of the three
# units gnome-remote-desktop ships would ever be enabled on their own even
# though `grdctl` could still configure the backend. Wired up below:
# the system daemon and its configuration daemon (both WantedBy
# graphical.target upstream), plus the per-session handover service that
# the system daemon passes authenticated clients to.
#
# Still doesn't turn RDP on by itself. System mode keeps its config in
# /etc/gnome-remote-desktop/grd.conf (mutable, owned by the
# gnome-remote-desktop user via the package's tmpfiles rules) and its
# credentials in that user's /var/lib/gnome-remote-desktop. Both are set
# once, by hand, as root:
#
#   # system mode will not serve without an explicit TLS cert/key —
#   # unlike headless mode it does not generate one for itself
#   openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
#     -subj /CN=apthos -out /etc/gnome-remote-desktop/tls.crt \
#     -keyout /etc/gnome-remote-desktop/tls.key
#   chown gnome-remote-desktop:gnome-remote-desktop /etc/gnome-remote-desktop/tls.{crt,key}
#   chmod 600 /etc/gnome-remote-desktop/tls.key
#
#   grdctl --system rdp set-tls-cert /etc/gnome-remote-desktop/tls.crt
#   grdctl --system rdp set-tls-key /etc/gnome-remote-desktop/tls.key
#   grdctl --system rdp set-credentials <username> <password>
#   grdctl --system rdp enable
#   grdctl --system status --show-credentials   # to check
#
# Caveat worth knowing before relying on this: GNOME gives each *user* a
# single systemd user instance, so a remote login as charlotte while the
# autologin session is already up means two concurrent graphical sessions
# sharing one gnome-session.target. Untested here; if the remote session
# comes up broken, give RDP its own account rather than fighting it.

{ config, ... }:

{
  services.gnome.gnome-remote-desktop.enable = true;

  assertions = [
    {
      assertion = config.services.displayManager.gdm.enable;
      message = ''
        modules/features/rdp.nix runs gnome-remote-desktop in system mode,
        which hands authenticated clients to GDM's remote display factory.
        No other display manager implements it, so enable
        services.displayManager.gdm on this host (see the module comment).
      '';
    }
  ];

  systemd.services = {
    # The --system daemon itself, plus the configuration daemon grdctl
    # --system talks to in order to write grd.conf.
    gnome-remote-desktop.wantedBy = [ "graphical.target" ];
    gnome-remote-desktop-configuration.wantedBy = [ "graphical.target" ];
  };

  # Runs inside each GNOME session (including GDM's own greeter session)
  # and is what actually receives the client from the system daemon. No
  # handover service in the session means no session to hand over to.
  systemd.user.services.gnome-remote-desktop-handover.wantedBy = [ "gnome-session.target" ];

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
