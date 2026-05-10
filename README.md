
# AVR Blinky Using Clang and Zig

Testing Zig's C interop for embedded AVR projects.

- [x] Step 1: Create a blinky project an build with AVR GCC
- [x] Step 2: Build with Clang
- [x] Step 3: Use 'zig cc' as drop-in Clang replacement (NOTE: must still link
  with avr-ld manually, no auto-invocation like Clang does)
- [x] Step 4: Add some Zig code.

- [x] Verify: Flash and run all builds on target

Deliberately created individual shell scripts for each build and keeping them
as similar as possible such that it is easy to diff and see the progression,
which is as follows:
- build-gcc
- build-clang
- build-zig-cc
- build-zig

## Findings

### Building with Clang

Found two parameter combinations that builds:
- 1: Hosted target:
    - `-target avr-unknown-unknown`
    - `-D__DELAY_BACKWARD_COMPATIBLE__`
- 2: Freestanding target:
    - `-target avr-freestanding`
    - `-ffreestanding`

Not entirely sure which is the most "correct" approach but option 1 seems to
be more similar to the default AVR GCC settings as `__STDC_HOSTED__=1`.
Currently the Clang build links against GCC's standard library and so both the
options above are likely valid. One important caveat is that Clang cannot
expand GCC built-in functions like the `__builtin_avr_delay_cycles`, which is
why the `-D__DELAY_BACKWARD_COMPATIBLE__` define is needed.

Moreover, it seems like Clang does not have linkage support for AVR targets:
If we omit the `--gcc-toolchain` and `--gcc-triple` compiler options  then the
linker produces the following warnings,
```
clang-21: warning: no avr-libc installation can be found on the system, cannot link standard libraries [-Wavr-rtlib-linking-quirks]
clang-21: warning: standard library not linked and so no interrupt vector table or compiler runtime routines will be linked [-Wavr-rtlib-linking-quirk
```

Interestingly, adding `--gcc-toolchain` and `--gcc-triple` and Clang now
simply opts for invoking `avr-ld` when linking instead of using its own
linker. Haven't looked into why this is the case, maybe it possible to link
with Clang if we can provide the linkerscript and point to AVR's libc (maybe
other components are needed as well?).

### Using Zig CC

To get the build to work with `zig cc` I had to add the `-mcpu` option in
addition to disabling debug symbols. Also, Zig doesn't accept
`-target avr-unknown-unknown` like Clang in case of hosted builds, and so I
had to change the target to `avr-freestanding` and add the `-fhosted` option.

When it comes to linking I highly doubt Zig has any additional AVR support
on top of what is provided by Clang. So unsurprisingly `zig cc` fails to link
the project. I was unable to make `zig cc` invoke `avr-ld` automatically like
Clang does.

### Porting main.c to main.zig

Initially thought I could leverage Zig's C interop to import `avr/io.h` and
`util/delay.h` to use the same register definitions and utility functions as
you would in a C-based AVR project. However this does not work due to
limitations in Zig's C translator. The register definitions uses pointer
casting and dereferencing which Zig is currently unable to deal with:
```c
#define _MMIO_BYTE(mem_addr) (*(volatile uint8_t *)(mem_addr))
```

Zig gives the following error:
```
cimport.zig:688:24: error: unable to translate C expr: unexpected token 'volatile'
pub const _MMIO_BYTE = @compileError("unable to translate C expr: unexpected token 'volatile'");
```

And for the delay utility functions it seems like it correctly in-lines
`_delay_ms` but fails to inline the nested `_delay_loop_2` which results in a
linker error.

Hence `main.zig` ends up not using any of GCC standard library at all though I
still link with GCC to avoid dealing with a custom linkerscript and startup
code.

Moreover, I initially tried using Zig version 0.16.0, but when trying to
compile main.zig I got the following error:
```
error: Alias and aliasee types don't match (Producer: 'zig 0.16.0' Reader: 'LLVM 21.1.8')
```

Chaning to Zig version 0.15.2 solved the problem (changed to stable branch in
nix flake).

### Using Zig's build system (not tested)

Should be possible to use Zig's build system with AVR projects though I would
recommend shelling out to `avr-ld` when linking.

Another caveat is that if the project has any C compile units that depend on
GCC built-ins then you would need to build those by invoking GCC through
opaque shell scripts. In that case you might need to manually encode
dependencies to get incremental rebuilds to work properly.

## Conclusion

Zig's C interop proved to be a bit to lacking to provide the `zig cc` drop in
replacement as advertised. My initial theory was that if I could get a working
Clang build up and running then integrating Zig using `zig cc` should be
trivial. This was almost true except that I had to fallback to invoking either
Clang or GCC directly at the link step. Linkning with Zig should still be
possible though, I just could not get it to work with `zig cc`.

Finally, when trying to port `main.c` to `main.zig` I found that I was unable
to leverage the GCC standard library and utilities for register definitions
and the delay function due to limitations in Zig C-translator. So unless your
project relies on legacy C code one might as well throw out AVR GCC entirely
and opt for a fully Zig-based project. That should be possible by providing
Zig with a linkerscript for your target (and maybe some startup code?).

