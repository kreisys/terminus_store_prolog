{
  description = "Prolog binding for terminusdb-store";

  inputs = {
    utils.url = "github:kreisys/flake-utils";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, utils, naersk }: utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-linux" ];

    overlay = final: prev: {
      swiplPacks = (prev.swiplPacks or {}) // {
        terminus_store_prolog = with final; let
          version = self.shortRev or "DIRTY";
          rust-bindings = naersk.lib.${final.system}.buildPackage {
            inherit version;
            pname = "cargo-crate-terminus_store_prolog";
            root = ./rust;
            buildInputs = [ final.clang final.swiProlog ];
            copyBins = false;
            copyLibs = true;
            LIBCLANG_PATH = "${final.libclang.lib}/lib";
          };
        in stdenv.mkDerivation {
          inherit version;
          pname = "swipl-pack-terminus_store_prolog";
          buildInputs = [ swiProlog ];
          src = ./.;

          buildPhase = ''
            rm Makefile
            libpath=lib/${system}
            mkdir -p $libpath
            for lib in ${rust-bindings}/lib/*; do
              ln -s $lib $libpath/libterminus_store.so
              ln -s $lib $libpath/libterminus_store.dylib
            done
          '';

          installPhase = ''
            mkdir -p $out/share/swi-prolog/pack
            swipl \
              -g "pack_install('file://$PWD', [package_directory('$_'), silent(true), interactive(false)])." -t "halt." 2>&1 | \
	            grep -v 'qsave(strip_failed' | \
	            (! grep -e ERROR -e Warning)
          '';
        };
      };
    };

    packages = { swiplPacks }: {
      defaultPackage = swiplPacks.terminus_store_prolog;
    };
  };
}
