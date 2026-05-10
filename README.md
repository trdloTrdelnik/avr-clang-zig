
# AVR Blinky Using Clang and Zig

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
Thus it seems like Clang does not have its own AVR standard library and relies
fully on GCC for linkerscripts, startup code and so on.

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

### Using Zig's build system

Should be possible to use Zig's build system with AVR projects though I would
recommend shelling out to `avr-ld` when linking.

Another caveat is that if the project has any C compile units that depend on
GCC built-ins then you would need to build those by invoking GCC through
opaque shell scripts. In that case you might need to manually encode
dependencies to get incremental rebuilds to work properly.

## Conclusion

AVR support in Clang (and also Zig) is limited when it comes to linking. AVR
projects are thus simply not the best testbed for testing out C interop with
`zig cc` as it's not the drop-in replacement as advertised.

To summarize:
- The AVR GCC toolchain is still needed (for providing startup code,
  linkerscripts, the standard library, linking etc.). Although it might be
  possible to extract the required components for a fully native Clang build.
- Any compile units that uses utilities from the GCC toolchain that depends on
  GCC built-ins must be compiled with `avr-gcc`.
- No debug information when building with Zig (seems to be a bug).


