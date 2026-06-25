{
  rustPlatform,
  fetchFromGitLab,
  gettext,
  pkg-config,
  meson,
  libdisplay-info,
  libdrm,
  libgbm,
  gtk3,
  libinput,
  pixman,
  seatd,
  udev,
  libxfce4ui,
  xfconf,
  libxkbcommon,
  xwayland,
  lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xfwl4";
  version = "4.21.0";

  src = fetchFromGitLab {
    domain = "gitlab.xfce.org";
    owner = "xfce";
    repo = "xfwl4";
    tag = "xfwl4-${finalAttrs.version}";
    hash = "sha256-k5RtaGYM0dIUPnRnbRbZIoURGOexAKHHuXaAKhQx3yQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-hg6Is+Wd1sMif0DugO72X5R8afbF7uzThbSHkhgjwEs=";

  nativeBuildInputs = [
    gettext
    pkg-config
    meson
    xwayland
  ];

  buildInputs = [
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
  ];

  strictDeps = true;

  enableParallelBuilding = true;

  meta = {
    description = "Xfce's Wayland Compositor";
    homepage = "https://gitlab.xfce.org/xfce/xfwl4";
    license = lib.licenses.gpl3Only;
    mainProgram = "xfwl4";
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
