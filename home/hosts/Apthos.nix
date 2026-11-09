# home/hosts/Apthos.nix

{ ... }:

{
  imports = [
    ../profiles/desktop-gnome.nix
    ../modules/oneshot-console.nix
    ../modules/oneshot-cursors.nix
    ../modules/oneshot-gtk.nix
    ../modules/oneshot-icons.nix
    ../modules/oneshot-wallpaper.nix
  ];

  # The 4K Sony TV on DP-1 (Sunshine-captured) wants 200% scaling. GNOME
  # keys ~/.config/monitors.xml on the display's EDID, so set it once by
  # hand in Settings > Displays after the first login; mutter persists it.
}
