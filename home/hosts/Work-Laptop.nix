# home/hosts/Work-Laptop.nix

{
  imports = [
    ../profiles/desktop-hyprland.nix
  ];

  # Not needed here (and its piper-tts dependency chain currently fails to build).
  my.hackyTts.enable = false;
}
