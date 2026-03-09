{ pkgs, sources }:

let
  lib = pkgs.lib;

  # Import your helper library
  ambxstLib = import ./nix/lib.nix;
in
ambxstLib.forAllSystems (
  system:
  let
    pkgs = import sources.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Import quickshell from sources if needed
    quickshell = import sources.quickshell { inherit pkgs; };

    Ambxst = import ./nix/packages {
      inherit
        pkgs
        lib
        sources
        system
        quickshell
        ambxstLib
        ;
      self = null;
    };
  in
  {
    default = Ambxst;
    Ambxst = Ambxst;

    # Optional: devShell
    devShell = pkgs.mkShell {
      packages = [ Ambxst ];
      shellHook = ''
        export QML2_IMPORT_PATH="${Ambxst}/lib/qt-6/qml:$QML2_IMPORT_PATH"
        export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
        echo "Ambxst dev environment loaded."
      '';
    };

    # Optional: apps
    apps = {
      default = {
        type = "app";
        program = "${Ambxst}/bin/ambxst";
      };
    };
  }
)
