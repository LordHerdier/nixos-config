# home/hosts/Apthos.nix

{ ... }:

{
  imports = [
    ../profiles/desktop-gnome.nix
  ];

  # Single 4K display (Sony TV over DP-1), captured by Sunshine for
  # Moonlight streaming, wants 200% scaling. GNOME keeps its monitor
  # layout/scaling in ~/.config/monitors.xml, keyed by the display's
  # real EDID vendor/product/serial — there's no clean way to pre-seed
  # that from Nix without those values, so set it by hand once in
  # Settings > Displays after the first login; mutter writes the file
  # itself from then on and it survives reboots/rebuilds.
}
