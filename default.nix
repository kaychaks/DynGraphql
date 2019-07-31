    { nixpkgs ? import (import ./nixpkgs.nix) {},
      compiler ? "default"}:
    let
      inherit (nixpkgs) pkgs;
      haskellPackages = pkgs.haskell.packages.${compiler};
      modHaskellPackages = haskellPackages.override (old: {
        overrides = self: super : {
          map-syntax = pkgs.haskell.lib.dontCheck super.map-syntax;
        };
      });
    in
        {
            DynGraphQL = modHaskellPackages.developPackage {
                returnShellEnv = false;
                root = ./.;
            };
        }
