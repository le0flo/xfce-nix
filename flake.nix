{
  description = "Xfce's development packages";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = {self, nixpkgs, ...}@inputs: let
    perSystem = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];

    callPackage = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in pkgs.lib.callPackageWith (pkgs // customPkgs system);

    customPkgs = system: nixpkgs.lib.genAttrs
      (builtins.attrNames (builtins.readDir ./pkgs))
      (name: callPackage system ./pkgs/${name}/package.nix {});
  in {
    packages = perSystem (system: {
                 xfwl4-debug = callPackage system ./pkgs/xfwl4/package.nix { buildType = "debug"; };
               } // (customPkgs system));

    overlays = perSystem (system: final: prev: customPkgs system);
  };
}
