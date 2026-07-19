{
  description = "Xfce's development packages";

  outputs = {self, nixpkgs, ...}@inputs: let
    perSystem = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];

    callPackage = system: (pkgs system).lib.callPackageWith (pkgs system // customPkgs system);

    pkgs = system: nixpkgs.legacyPackages.${system};
    
    customPkgs = system: nixpkgs.lib.genAttrs
      (builtins.attrNames (builtins.readDir ./pkgs))
      (name: callPackage system ./pkgs/${name}/package.nix {});
  in {
    packages = perSystem (system: customPkgs system);

    overlays = perSystem (system: final: prev: customPkgs system);

    devShells = perSystem (system: let
      shellPkgs = (pkgs system).extend self.overlays.${system};
    in {
      xfwl4-dev = shellPkgs.mkShell {
        packages = with shellPkgs; [
          gettext
          pkg-config
          meson
          xwayland
          cargo
          rustc
        ];

        buildInputs = with shellPkgs; [
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
      };
    });
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
}
