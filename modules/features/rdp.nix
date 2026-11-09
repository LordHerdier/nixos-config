# modules/features/rdp.nix
#
# GNOME's built-in RDP server (gnome-remote-desktop), for a workstation
# session from an iPad etc. (Sunshine/Moonlight is tuned for games: no
# clipboard/file niceties).
#
# Runs in *system* mode (grdctl --system; Settings' "Remote Login"). The
# other modes conflict with Sunshine on the autologin session: screen
# sharing fights over its cursor and display mode, and headless mode
# grabs Mutter's RemoteDesktop portal at startup, so Sunshine hangs waiting
# for it and never opens its ports.
#
# In system mode the daemon runs as the `gnome-remote-desktop` user and,
# once a client authenticates, asks GDM for a new remote display
# (org.gnome.DisplayManager.RemoteDisplayFactory) and hands the client to
# that session's handover service. The autologin session is never touched,
# so this can stay always-on. Only GDM implements RemoteDisplayFactory
# (without it clients hang at handover), hence the assertion and Apthos
# using GDM.
#
# NixOS ignores packages' [Install] sections, so the three units are
# enabled below by hand.
#
# RDP still needs enabling once, by hand, as root. Config lives in
# /etc/gnome-remote-desktop/grd.conf, credentials in
# /var/lib/gnome-remote-desktop:
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
# Caveat: each user gets one systemd user instance, so a remote login as
# charlotte alongside the autologin session means two graphical sessions
# sharing one gnome-session.target. Untested; if it comes up broken, give
# RDP its own account.

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
    # The --system daemon, and the configuration daemon grdctl --system
    # uses to write grd.conf.
    gnome-remote-desktop.wantedBy = [ "graphical.target" ];
    gnome-remote-desktop-configuration.wantedBy = [ "graphical.target" ];
  };

  # Runs in each GNOME session (GDM's greeter included) and receives the
  # client from the system daemon.
  systemd.user.services.gnome-remote-desktop-handover.wantedBy = [ "gnome-session.target" ];

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
