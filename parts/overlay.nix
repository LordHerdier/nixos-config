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
  # The screen shader (72-screen-shader.patch) is hyprCRT's, the same
  # one the Hyprland session uses.
  dwl = final.callPackage ../pkgs/dwl {
    inherit (prev) dwl;
    screenShader = "${
      inputs.hyprCRT-shader.packages.${final.stdenv.hostPlatform.system}.default
    }/share/hyprCRT/crt.frag";
  };
  dwl-clangd = final.callPackage ../pkgs/dwl/clangd.nix { };

  # slstatus feeding dwl's bar -- see pkgs/slstatus.
  slstatus = final.callPackage ../pkgs/slstatus { inherit (prev) slstatus; };

  # st-wl, the Wayland st the dwl session launches -- see pkgs/st-wl.
  st-wl = final.callPackage ../pkgs/st-wl { };

  # Pelican game panel's node daemon -- see pkgs/pelican-wings.
  pelican-wings = final.callPackage ../pkgs/pelican-wings { };

  oneshot-cursors = final.callPackage ../pkgs/oneshot-cursors { };
  oneshot-gtk-theme = final.callPackage ../pkgs/oneshot-gtk-theme { };
  oneshot-icons = final.callPackage ../pkgs/oneshot-icons { };
  oneshot-wallpaper = final.callPackage ../pkgs/oneshot-wallpaper { };
}
