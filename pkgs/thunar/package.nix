{
  stdenv,
  lib,
  makeWrapper,
  symlinkJoin,
  fetchFromGitLab,
  docbook_xsl,
  gettext,
  xfce4-exo,
  gdk-pixbuf,
  gtk3,
  libexif,
  libgudev,
  libnotify,
  libx11,
  libxfce4ui,
  libxfce4util,
  libxslt,
  pcre2,
  pkg-config,
  xfce4-dev-tools,
  xfce4-panel,
  xfconf,
  wrapGAppsHook3,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
  buildPackages,
  gobject-introspection,
  gitUpdater,
  thunarPlugins ? [ ],
}:

let
  thunar = stdenv.mkDerivation (finalAttrs: {
    pname = "thunar";
    version = "4.20.8";

    outputs = [
      "out"
      "dev"
    ];

    src = fetchFromGitLab {
      domain = "gitlab.xfce.org";
      owner = "xfce";
      repo = "thunar";
      tag = "thunar-${finalAttrs.version}";
      hash = "sha256-gcNo9HNBY5NGhJ8N8DBTXYb5gsNAXrItvWuo3XdSBRg=";
    };

    nativeBuildInputs = [
      docbook_xsl
      gettext
      libxslt
      pkg-config
      xfce4-dev-tools
      wrapGAppsHook3
    ]
    ++ lib.optionals withIntrospection [
      gobject-introspection
    ];

    buildInputs = [
      xfce4-exo
      gdk-pixbuf
      gtk3
      libx11
      libexif # image properties page
      libgudev
      libnotify
      libxfce4ui
      libxfce4util
      pcre2 # search & replace renamer
      xfce4-panel # trash panel applet plugin
      xfconf
    ];

    configureFlags = [
      "--enable-maintainer-mode"
      "--with-custom-thunarx-dirs-enabled"
    ];

    # Some example/plugin targets include libxfce4ui headers without attaching
    # libxfce4util's include path themselves.
    env.NIX_CFLAGS_COMPILE = "-I${lib.getDev libxfce4util}/include/xfce4";
    env.NIX_LDFLAGS = "-lxfce4util";

    enableParallelBuilding = true;

    # the desktop file … is in an insecure location»
    # which pops up when invoking desktop files that are
    # symlinks to the /nix/store
    #
    # this error was added by this commit:
    # https://github.com/xfce-mirror/thunar/commit/1ec8ff89ec5a3314fcd6a57f1475654ddecc9875
    postPatch = ''
      sed -i -e 's|thunar_dialogs_show_insecure_program (parent, _(".*"), file, exec)|1|' thunar/thunar-file.c
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        # https://github.com/NixOS/nixpkgs/issues/329688
        --prefix PATH : ${lib.makeBinPath [ xfce4-exo ]}
      )
    '';

    passthru.updateScript = gitUpdater {
      rev-prefix = "thunar-";
      odd-unstable = true;
    };

    meta = {
      description = "Xfce file manager";
      homepage = "https://gitlab.xfce.org/xfce/thunar";
      license = lib.licenses.gpl2Plus;
      mainProgram = "thunar";
      platforms = lib.platforms.linux;
      teams = [ lib.teams.xfce ];
    };
  });
in
if thunarPlugins == [ ] then
  thunar
else
  symlinkJoin {
    name = "thunar-with-plugins-${thunar.version}";
    paths = [ thunar ] ++ thunarPlugins;
    nativeBuildInputs = [ makeWrapper ];

    postBuild = ''
      wrapProgram "$out/bin/thunar" \
        --set "THUNARX_DIRS" "$out/lib/thunarx-3"

      wrapProgram "$out/bin/thunar-settings" \
        --set "THUNARX_DIRS" "$out/lib/thunarx-3"

      rm -f "$out/lib/systemd/user"
      mkdir -p "$out/lib/systemd/user"

      for file in "lib/systemd/user/thunar.service" \
        "share/dbus-1/services/org.xfce.FileManager.service" \
        "share/dbus-1/services/org.xfce.Thunar.FileManager1.service" \
        "share/dbus-1/services/org.xfce.Thunar.service"
      do
        rm -f "$out/$file"
        substitute "${thunar}/$file" "$out/$file" \
          --replace "${thunar}" "$out"
      done
    '';

    meta = {
      inherit (thunar.meta)
        homepage
        license
        platforms
        teams
        ;

      description =
        thunar.meta.description
        + lib.optionalString (thunarPlugins != [ ])
          " (with plugins: ${lib.concatStringsSep ", " (map (x: x.name) thunarPlugins)})";
    };
  }
