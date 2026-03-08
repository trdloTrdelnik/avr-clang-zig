{ pkgs ? import <nixpkgs> {} }:

let
  avr-gcc = pkgs.callPackage ./avr-toolchain.nix {};
in

pkgs.mkShell {
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
    echo "AVR Toolchain: ${avr-gcc.version}"
    echo ""
    echo "Available commands:"
    echo "  avr-gcc --version"
    echo "  avr-objcopy --help"
    echo "  avrdude -c help"
    echo ""
  '';
}
