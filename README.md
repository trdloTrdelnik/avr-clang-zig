# README

Experimenting trying to build an AVR project with Zig.

- [x] Step 1: Create a blinky project an build with AVR GCC
- [x] Step 2: Build with Clang
- [ ] Step 3: Use 'zig cc' as drop-in Clang replacement
- [ ] Step 4: Port main.c to main.zig
- [ ] Verify: Flash and run all builds on target

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

