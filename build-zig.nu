#!/usr/bin/env nu

use utils.nu print-and-run-cmd

const OUTPUT_DIR = path self ./build-zig/
const MAIN_OBJ_FILE = $OUTPUT_DIR | path join main.o
const MAIN_ELF_FILE = $OUTPUT_DIR | path join main.elf

if (not ($OUTPUT_DIR | path exists)) {
	mkdir $OUTPUT_DIR
}

# Target microcontroller
const MCU = "atmega324pa" # pb not fully supported

# Clock frequency
const F_CPU = "1000000UL" # 1MHz

# Compiler and tools
const CC = [zig cc]
const LD = "avr-gcc"

let gcc_install = which avr-gcc | get path | first | path dirname | path join ".." | path expand

# Found by querying avr-gcc -E -v -x c++ /dev/null
let system_includes = [
	lib/gcc/avr/7.3.0/include
	lib/gcc/avr/7.3.0/include-fixed
	lib/gcc/avr/7.3.0/../../../../avr/include
] | each { |e| $gcc_install | path join $e } |
	each { |e| $"-isystem ($e)" | split row " " } |
	flatten

let COMMON_FLAGS = [
	-mmcu=($MCU)
	-DF_CPU=($F_CPU)
]

# Compiler flags
let CFLAGS = [
	-Os
	-Wall
	-Wextra
	-std=c99
	# -g # zig compiler doesn't like adding debug symbols..
	-c
	-ffunction-sections
	-fdata-sections
	-D__DELAY_BACKWARD_COMPATIBLE__
	-fno-builtin
	-fno-sanitize=undefined
	# -gdwarf-4 # zig compiler doesn't like adding debug symbols..
] | append $system_includes

let clang_options = [
	-target avr-freestanding # Zig does not accept avr-unknown-unknown
	-fhosted # to set __STDC_HOSTED__=1
	-mcpu=($MCU) # zig needs both -mmcu and -mcpu for some reason..
	--gcc-toolchain=($gcc_install)
	--gcc-triple=avr
]

# Linker flags
let LDFLAGS = [
	--gc-sections
	-lgcc
] | each { |e| $"-Wl,($e)" }

print $"(ansi green)Building(ansi reset)"
print-and-run-cmd $CC ...$COMMON_FLAGS ...$CFLAGS ...$clang_options ...[
	-save-temps=obj
	main.c
	-o $MAIN_OBJ_FILE
]

print $"(ansi green)Linking(ansi reset)"
print-and-run-cmd $LD ...$COMMON_FLAGS ...$LDFLAGS ...[
	$MAIN_OBJ_FILE
	-o $MAIN_ELF_FILE
]
