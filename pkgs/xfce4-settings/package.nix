{
  stdenv,
  lib,
  fetchFromGitLab,
  gettext,
  pkg-config,
  meson,
  ninja,
  python3,
  wayland-scanner,
  wrapGAppsHook3,
  xfce4-exo,
  garcon,
  gtk3,
  gtk-layer-shell,
  glib,
  libnotify,
  libx11,
  libxkbcommon,
  libxext,
  libxfce4ui,
  libxfce4util,
  libxklavier,
  libxml2,
  bashNonInteractive,
  withXrandr ? true,
  upower,
  # Disabled by default on upstream and actually causes issues:
  # https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/222
  withUpower ? false,
  wlr-protocols,
  xapp,
  xfconf,
  xf86-input-libinput,
  colord,
  withColord ? true,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-settings";
  version = "4.21.2";

  src = fetchFromGitLab {
    domain = "gitlab.xfce.org";
    owner = "xfce";
    repo = "xfce4-settings";
    tag = "xfce4-settings-${finalAttrs.version}";
    hash = "sha256-Wy2csQm2jY2ur5XH++boC3ZLRu64tBNMkTIIBDg1Aq0=";
    fetchSubmodules = true;
  };

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    gettext
    pkg-config
    meson
    ninja
    python3
    wayland-scanner
    wrapGAppsHook3
    libxml2
  ];

  buildInputs = [
    bashNonInteractive
    xfce4-exo
    garcon
    glib
    gtk3
    gtk-layer-shell
    libnotify
    libx11
    libxkbcommon
    libxext
    libxfce4ui
    libxfce4util
    libxklavier
    wlr-protocols
    xapp # org.x.apps.portal
    xf86-input-libinput
    xfconf
  ]
  ++ lib.optionals withUpower [ upower ]
  ++ lib.optionals withColord [ colord ];

  strictDeps = true;

  mesonFlags = [
    (lib.mesonOption "sound-settings" "true")
    (lib.mesonOption "xrandr" "${if withXrandr then "enabled" else "disabled"}")
  ]
  ++ lib.optionals withUpower [ (lib.mesonOption "upower" "true") ]
  ++ lib.optionals withUpower [ (lib.mesonOption "colord" "true") ];

  postPatch = ''
    # Upstream forgot to attach libxfce4util to the display-settings target.
    # Nix builds are strict enough to expose the missing include path.
    sed -i '/libxfce4ui,/a\libxfce4util,' dialogs/display-settings/meson.build
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-settings-";
    odd-unstable = true;
  };

  meta = {
    description = "Settings manager for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/xfce4-settings";
    license = lib.licenses.gpl2Plus;
    mainProgram = "xfce4-settings-manager";
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
