
# README

Experimenting trying to build an AVR project with Zig.

- [x] Step 1: Create a blinky project an build with AVR GCC
- [x] Step 2: Build with Clang
- [x] Step 3: Use 'zig cc' as drop-in Clang replacement (NOTE: must still link
  with avr-ld manually, no auto-invocation like Clang does)
- [ ] Step 4: Add some Zig code.

- [x] Verify: Flash and run all builds on target

## Findings

### Building with Clang

Found two parameter combinations that builds:
- 1: non-freestanding target with options:
    - `-target avr-unknown-unknown`
    - `-D__DELAY_BACKWARD_COMPATIBLE__`

 - 2: freestanding target
    - `-target avr-freestanding`
    - `-ffreestanding`

Option 1 is more similar to the GCC build because then `__STDC_HOSTED__=1`,
however, we most likely want to set `__STDC_HOSTED__=0` when building with
Clang. This is because Clang cannot expand GCC's built-ins, like
`__builtin_avr_delay_cycles` used in `delay.h`. In other words, Clang isn't
hosting the standard library despite being able to find and use its includes.

Moreover, it seems like Clang does not have linkage support for AVR targets:
If we omit the `--gcc-toolchain` and `--gcc-triple` compiler options  then the
linker produces the following warnings,
```
clang-21: warning: no avr-libc installation can be found on the system, cannot link standard libraries [-Wavr-rtlib-linking-quirks]
clang-21: warning: standard library not linked and so no interrupt vector table or compiler runtime routines will be linked [-Wavr-rtlib-linking-quirk
```
Thus it seems like Clang does not have its own AVR standard library and relies
fully on GCC for linkerscripts, startup code and so on.

Adding `--gcc-toolchain` and `--gcc-triple` and Clang now simply opts for
invoking `avr-ld` when linking instead of using its own linker.

### Using Zig CC

To get the build to work with `zig cc` I had to add the `-mcpu` option in
addition to disabling debug symbols.

When it comes to linking I highly doubt Zig has any additional AVR support
on top of what is provided by Clang. So unsurprisingly `zig cc` fails to link
the project. Despite many attempts I was unable to make `zig cc` invoke
`avr-ld` automatically like Clang.

### Using Zig's build system

Zig's build system currently has no support for invoking GCC other than
through opaque shell scripts. This adds some friction for compile units that
need to be built with GCC (e.g. code that depend on GCC built-ins) as one will
have to manually encode dependencies to get incremental rebuilds to work
properly.

In addition, linking must be done with `avr-ld`.

## Conclusion

AVR support in Clang is limited (and by extension also Zig because I think all
of Zig's AVR support comes exclusively from Clang). AVR projects are thus
simply not the best testbed for testing out C interop with `zig cc` as it's
not the drop-in replacement that it would be.

Based on the above findings, any Zig or Clang based AVR project must accept
the following limitations:
- The AVR GCC toolchain is still needed (for providing startup code,
  linkerscripts, the standard library, linking etc.).
- Linking still has to be done with avr-ld (and this imposes constraints on
  debug symbols, maybe other things?)
- Any compile units that uses standard library function that depends on GCC
  built-ins must be compiled with `avr-gcc`.


