# modules/features/steam.nix

{ pkgs, ... }:

{
  # mangoapp (shipped by mangohud) is the overlay process gamescope spawns
  # when STEAM_USE_MANGOAPP=1; it must be on PATH. Toggle in-game with
  # Shift_R+F12; configure via ~/.config/MangoHud/MangoHud.conf.
  environment.systemPackages = [ pkgs.mangohud ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # A "Steam" Wayland session (Big Picture inside gamescope). Also enables
    # programs.gamescope, whose cap_sys_nice --rt uses. SDDM/GDM list it by
    # themselves; Index's tuigreet is pointed at the session dir.
    gamescopeSession = {
      enable = true;
      args = [
        "--rt"
        "--adaptive-sync"
      ];
      # Spawn mangoapp with the session; the overlay starts hidden.
      env.STEAM_USE_MANGOAPP = "1";
    };
  };
}
