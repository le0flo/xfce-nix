{pkgs}:

pkgs.mkShell {
  packages = with pkgs; [
    gettext
    pkg-config
    meson
    xwayland
    cargo
    rustc
  ];

  buildInputs = with pkgs; [
    libdisplay-info
    libdrm
    libgbm
    gtk3
    libinput
    pixman
    seatd
    udev
    libxfce4ui
    xfconf
    libxkbcommon
    wayland
    libglvnd
  ];
}
