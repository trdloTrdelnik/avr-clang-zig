#!/usr/bin/env nu


const OUTPUT_DIR = path self ./build-clang/
const MAIN_OBJ_FILE = $OUTPUT_DIR | path join main.o
const MAIN_ELF_FILE = $OUTPUT_DIR | path join main.elf

# Target microcontroller
const MCU = "atmega328p"

# Clock frequency (16MHz for Arduino Uno)
const F_CPU = "16000000UL"

# Compiler and tools
const CC = "clang-20"

let GCC_INSTALL = which avr-gcc | get path path | first | path dirname | path join ".." | path expand

# Found by querying avr-gcc -E -v -x c++ /dev/null
let SYSTEM_INCLUDES = [
	lib/gcc/avr/7.3.0/include
	lib/gcc/avr/7.3.0/include-fixed
	lib/gcc/avr/7.3.0/../../../../avr/include
] | each { |e| $GCC_INSTALL | path join $e } |
	each { |e| $"-isystem ($e)" | split row " " } |
	flatten

# Compiler flags
let CFLAGS = [
	-target avr-freestanding
	-ffreestanding
	-mmcu=($MCU)
	-DF_CPU=($F_CPU)
	-Os
	-Wall
	-Wextra
	-std=c99
	-fno-builtin
	-gdwarf-4
	--gcc-toolchain=($GCC_INSTALL)
	--gcc-triple=avr
] | append $SYSTEM_INCLUDES

# Linker flags
let LDFLAGS = [
	--gc-sections
	-lgcc
] | each { |e| $"-Wl,($e)" }

print $"(ansi green)Building(ansi reset)"
let ALL_BUILD_ARGS = $CFLAGS ++ [
	-g
	-ffunction-sections
	-fdata-sections
	-save-temps=obj
	-c
	main.c
	-o $MAIN_OBJ_FILE
]
let cmd_string = $"($CC) ($ALL_BUILD_ARGS | str join ' ')"
print $"(ansi blue)($cmd_string)(ansi reset)"
^$CC -v ...$ALL_BUILD_ARGS

print $"(ansi green)Linking(ansi reset)"
^$CC -v ...$CFLAGS ...$LDFLAGS ...[
	$MAIN_OBJ_FILE
	-o $MAIN_ELF_FILE
]
