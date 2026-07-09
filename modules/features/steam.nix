# home/modules/features/steam.nix

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

    # Dedicated gamescope Steam session for a console-like experience.
    # Registers a "Steam" Wayland session (share/wayland-sessions/steam.desktop)
    # that display managers can launch. It runs:
    #   gamescope --steam -- steam -tenfoot -pipewire-dmabuf
    # i.e. Steam Big Picture inside gamescope as its own compositor.
    # This also enables programs.gamescope (grants cap_sys_nice).
    #
    # Pine (SDDM) lists this automatically. Index (greetd + tuigreet) needs
    # tuigreet pointed at the session dir to offer it — see hosts/Index.
    gamescopeSession = {
      enable = true;
      # --rt: realtime scheduling for smoother frame pacing (uses the
      #       cap_sys_nice that programs.gamescope grants).
      # --adaptive-sync: VRR / FreeSync / G-Sync passthrough on capable displays.
      args = [
        "--rt"
        "--adaptive-sync"
      ];
      # Spawn the MangoHud overlay (mangoapp) with the session. It's off by
      # default and toggled at runtime with Shift_R+F12 — not a rebuild.
      env.STEAM_USE_MANGOAPP = "1";
    };
  };
}
