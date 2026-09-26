# modules/profiles/desktop-gnome.nix
#
# A plain GNOME Wayland session, added alongside Hyprland rather than
# replacing it. Intended for the "kiddo" account: one Activities button,
# big click targets, nothing to accidentally take apart.
#
# Deliberately enables NO display manager. Index drives logins through
# greetd + tuigreet, and enabling gdm here would collide with it.
# services.desktopManager.gnome.enable registers the session in
# services.displayManager.sessionData.desktops on its own, which is what
# tuigreet's --sessions flag reads, so the session shows up under F3
# without a GNOME-specific greeter.

{ pkgs, ... }:

{
  services.desktopManager.gnome.enable = true;

  # Mahjongg, sudoku, Quadrapassel and friends — genuinely the right
  # difficulty level for a six-year-old, and they cost almost nothing.
  services.gnome.games.enable = true;

  # GNOME apps land in environment.systemPackages, so this prunes the
  # whole machine, not just her session. Everything dropped here either
  # duplicates something Charlotte already uses (console/kitty) or is
  # an account-shaped dead end for a kid (Geary, Contacts, Connections).
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    gnome-contacts
    geary
    epiphany
  ];

  # GNOME's settings daemon wants these; harmless if another profile
  # already turned them on.
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;
}
