{ nixpkgs ? import (import ./nixpkgs.nix) {}, compiler ? "default", withHoogle ? false}:
    let
      inherit (nixpkgs) pkgs;
      
      haskellPackages = if compiler == "default"
      then pkgs.haskellPackages
      else pkgs.haskell.packages.${compiler};
      
      project = import ./. { inherit nixpkgs compiler; };
    in
    with haskellPackages;
    shellFor {
      inherit withHoogle;
      packages = p: [ project.DynGraphql ];
      buildInputs = [
                  ghcid
                  snap-templates
      ];
    }
