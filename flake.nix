{
  description = "Xfce's development packages";

  outputs = {self, nixpkgs, ...}@inputs: let
    lib = nixpkgs.lib;

    pkgs = system: nixpkgs.legacyPackages.${system};
    callPackage = system: (pkgs system).lib.callPackageWith (pkgs system // customPkgs system);
    perSystem = lib.genAttrs [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];

    customPkgs = system: lib.genAttrs
      (builtins.attrNames (builtins.readDir ./pkgs))
      (name: callPackage system ./pkgs/${name}/package.nix {});
  in {
    packages = perSystem (system: customPkgs system);

    overlays = perSystem (system: final: prev: customPkgs system);

    devShells = perSystem (system: lib.genAttrs
      (builtins.filter
        (name: builtins.pathExists ./pkgs/${name}/shell.nix)
        (builtins.attrNames (builtins.readDir ./pkgs)))
      (name: callPackage system ./pkgs/${name}/shell.nix {
        pkgs = (pkgs system).extend self.overlays.${system};
      }));
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
}
