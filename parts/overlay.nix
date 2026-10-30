inputs: final: prev: {
  concord = inputs.concord.packages.${final.stdenv.hostPlatform.system}.default;

  # Not a customised Console, just one with an
  # upstream bug fixed -- see pkgs/gnome-console.
  # `prev` is passed explicitly because callPackage
  # would otherwise hand the override itself back in.
  gnome-console = final.callPackage ../pkgs/gnome-console {
    inherit (prev) gnome-console;
  };

  # dwl with our config.h and patch stack -- see pkgs/dwl.
  # `prev` for the same reason as gnome-console above.
  dwl = final.callPackage ../pkgs/dwl { inherit (prev) dwl; };
  dwl-clangd = final.callPackage ../pkgs/dwl/clangd.nix { };

  # slstatus feeding dwl's bar -- see pkgs/slstatus.
  slstatus = final.callPackage ../pkgs/slstatus { inherit (prev) slstatus; };

  oneshot-cursors = final.callPackage ../pkgs/oneshot-cursors { };
  oneshot-gtk-theme = final.callPackage ../pkgs/oneshot-gtk-theme { };
  oneshot-icons = final.callPackage ../pkgs/oneshot-icons { };
  oneshot-wallpaper = final.callPackage ../pkgs/oneshot-wallpaper { };
}
