{
  description = "AVR development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        avr-gcc = pkgs.callPackage ./avr-toolchain.nix {};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            avr-gcc
            avrdude
            gnumake
            zig
            clang_21
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
