{
  stdenv,
  lib,
  fetchFromGitLab,
  glib,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  gspell,
  gtk3,
  gtksourceview4,
  libxfce4ui,
  libxfce4util,
  xfconf,
  enablePolkit ? true,
  polkit,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mousepad";
  version = "0.7.0";

  src = fetchFromGitLab {
    domain = "gitlab.xfce.org";
    owner = "apps";
    repo = "mousepad";
    tag = "mousepad-${finalAttrs.version}";
    hash = "sha256-zoPzMqXfY3ir8MOYXTr+ZNmxISdMgKQEWwIgsVD9oMw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib # glib-compile-schemas
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gspell
    gtk3
    gtksourceview4
    libxfce4ui # for shortcut plugin
    libxfce4util
    xfconf # required by libxfce4kbd-private-3
  ]
  ++ lib.optionals enablePolkit [
    polkit
  ];

  # Use the GSettings keyfile backend rather than the default
  mesonFlags = [ "-Dkeyfile-settings=true" ];

  postPatch = ''
    # Upstream forgot to attach libxfce4util to the shortcuts plugin target.
    sed -i "/dependency('libxfce4ui-2'/a\  deps += dependency('libxfce4util-1.0', version: dependency_versions['libxfce4ui'], required: get_option('shortcuts-plugin'))" meson.build
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "mousepad-"; };

  meta = {
    description = "Simple text editor for Xfce";
    homepage = "https://gitlab.xfce.org/apps/mousepad";
    license = lib.licenses.gpl2Plus;
    mainProgram = "mousepad";
    teams = [ lib.teams.xfce ];
    platforms = lib.platforms.linux;
  };
})
