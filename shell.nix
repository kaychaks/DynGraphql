{ nixpkgs ? import (import ./nixpkgs.nix) {}, compiler ? "default", withHoogle ? false}:
    let
      inherit (nixpkgs) pkgs;
      haskellPackages = pkgs.haskell.packages.${compiler};
      project = import ./. { inherit nixpkgs compiler; };
    in
    with haskellPackages;
    shellFor {
      inherit withHoogle;
      packages = p: [ project.DynGraphQL ];
      buildInputs = [
                  ghcid
                  snap-templates
      ];
    }
