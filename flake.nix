{
  description = "AVR development environment";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # zig 0.16.0 compiling for AVR is broken, use 0.15.2
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # cross = pkgs.pkgsCross.avr;
        #
        # avr-gcc = cross.buildPackages.gcc;
        # avr-binutils = cross.buildPackages.binutils;
        # avr-libc = cross.avrlibc;
        avr-gcc = pkgs.callPackage ./avr-toolchain.nix {};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            avr-gcc
            avrdude
            gnumake
            zig
            clang_20
          ];

          shellHook = ''
            echo "AVR Development Environment"
            echo "=========================="
            echo "System: ${system}"
            echo "AVR Toolchain: ${avr-gcc.version}"
            echo ""
            echo "Available commands:"
            echo "  avr-gcc --version"
            echo "  avr-objcopy --help"
            echo "  avrdude -c help"
            echo ""
          '';
        };
      }
    );
}
