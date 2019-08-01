    { nixpkgs ? import (import ./nixpkgs.nix) {},
      compiler ? "default"}:
    let
      inherit (nixpkgs) pkgs;

      haskellPackages = if compiler == "default"
      then pkgs.haskellPackages
      else pkgs.haskell.packages.${compiler};

      modHaskellPackages = haskellPackages.override (old: {
        overrides = self: super : {
          map-syntax = pkgs.haskell.lib.dontCheck super.map-syntax;
          http-streams = pkgs.haskell.lib.doJailbreak super.http-streams;
        };
      });
    in
        {
            DynGraphql = modHaskellPackages.developPackage {
                returnShellEnv = false;
                root = ./.;
            };
        }
