#!/usr/bin/env nu

const OUTPUT_DIR = path self ./build-zig/
const MAIN_OBJ_FILE = $OUTPUT_DIR | path join main.o
const MAIN_ELF_FILE = $OUTPUT_DIR | path join main.elf

if (not ($OUTPUT_DIR | path exists)) {
	mkdir $OUTPUT_DIR
}

# Target microcontroller
const MCU = "atmega328p"

# Clock frequency (16MHz for Arduino Uno)
const F_CPU = "16000000UL"

# Compiler and tools
const CC = [zig cc]
const LD = "clang-20"

let gcc_install = which avr-gcc | get path | first | path dirname | path join ".." | path expand

# Found by querying avr-gcc -E -v -x c++ /dev/null
let system_includes = [
	lib/gcc/avr/7.3.0/include
	lib/gcc/avr/7.3.0/include-fixed
	lib/gcc/avr/7.3.0/../../../../avr/include
] | each { |e| $gcc_install | path join $e } |
	each { |e| $"-isystem ($e)" | split row " " } |
	flatten

# Compiler flags
let c_flags = [
	-mmcu=($MCU)
	-DF_CPU=($F_CPU)
	-Os
	-Wall
	-Wextra
	-std=c99
	-fno-builtin
	-fno-sanitize=undefined
	# -gdwarf-4 # zig compiler doesn't like adding debug symbols..
] | append $system_includes

let clang_options = [
	-ffreestanding
	-target avr-freestanding
	-mcpu=($MCU) # zig needs both -mmcu and -mcpu for some reason..
	--gcc-toolchain=($gcc_install)
	--gcc-triple=avr
]

# Linker flags
let ld_flags = [
	--gc-sections
	-lgcc
] | each { |e| $"-Wl,($e)" }

# Build
print $"(ansi green)Building(ansi reset)"
let all_build_flags = $c_flags ++ $clang_options ++ [
	# -g # zig compiler doesn't like adding debug symbols..
	# -rtlib=none
	-ffunction-sections
	-fdata-sections
	-save-temps=obj
	-c
	main.c
	-o $MAIN_OBJ_FILE
]
let cmd_string = $"($CC | str join ' ') ($all_build_flags | str join ' ')"
print $"(ansi blue)($cmd_string)(ansi reset)"
^$CC ...$all_build_flags -v

# Link
let all_link_args = [
	...$c_flags
	...$clang_options
	...$ld_flags
	$MAIN_OBJ_FILE
	-o $MAIN_ELF_FILE
]
print $"(ansi green)Linking(ansi reset)"
let cmd_string = $"($LD) ($all_link_args | str join ' ')"
print $"(ansi blue)($cmd_string)(ansi reset)"
^$LD ...$all_link_args -v
