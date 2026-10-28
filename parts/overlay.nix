final: prev: {
  concord = final.callPackage ../pkgs/concord.nix { };

  # Not a customised Console, just one with an
  # upstream bug fixed -- see pkgs/gnome-console.
  # `prev` is passed explicitly because callPackage
  # would otherwise hand the override itself back in.
  gnome-console = final.callPackage ../pkgs/gnome-console {
    inherit (prev) gnome-console;
  };

  oneshot-cursors = final.callPackage ../pkgs/oneshot-cursors { };
  oneshot-gtk-theme = final.callPackage ../pkgs/oneshot-gtk-theme { };
  oneshot-icons = final.callPackage ../pkgs/oneshot-icons { };
  oneshot-wallpaper = final.callPackage ../pkgs/oneshot-wallpaper { };
}
