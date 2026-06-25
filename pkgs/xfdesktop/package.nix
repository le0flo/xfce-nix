{
  stdenv,
  lib,
  fetchFromGitLab,
  gettext,
  pkg-config,
  meson,
  ninja,
  python3,
  wrapGAppsHook3,
  xfce4-exo,
  gtk3,
  libxfce4ui,
  libxfce4util,
  libxfce4windowing,
  libyaml,
  xfconf,
  libnotify,
  garcon,
  gtk-layer-shell,
  thunar,
  gitUpdater,
  gst_all_1,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfdesktop";
  version = "4.21.0";

  src = fetchFromGitLab {
    domain = "gitlab.xfce.org";
    owner = "xfce";
    repo = "xfdesktop";
    tag = "xfdesktop-${finalAttrs.version}";
    hash = "sha256-Ac6f/qsgrrWK8/kNF+fBFCnDDNMuyjQoTYeaPeV5cNY=";
  };

  nativeBuildInputs = [
    gettext
    pkg-config
    meson
    ninja
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    xfce4-exo
    gtk3
    libxfce4ui
    libxfce4util
    libxfce4windowing
    libyaml
    xfconf
    libnotify
    garcon
    gtk-layer-shell
    thunar
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfdesktop-";
    odd-unstable = true;
  };

  meta = {
    description = "Xfce's desktop manager";
    homepage = "https://gitlab.xfce.org/xfce/xfdesktop";
    mainProgram = "xfdesktop";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
