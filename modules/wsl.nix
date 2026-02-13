# modules/wsl.nix

{ ... }:

{
  wsl = {
    enable = true;
    defaultUser = "charlotte";
    startMenuLaunchers = true;
    wslConf.interop.appendWindowsPath = false;
  };
}
