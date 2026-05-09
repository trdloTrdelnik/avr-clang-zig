#!/usr/bin/env nu

use utils.nu print-and-run-cmd

const OUTPUT_DIR = path self ./build-gcc/
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
const CC = "avr-gcc"
const LD = "avr-gcc"

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
	-g
	-c
	-ffunction-sections
	-fdata-sections
	-D__DELAY_BACKWARD_COMPATIBLE__ # Not really needed but to better match clang build for comparison
]

# Linker flags
let LDFLAGS = [
	--gc-sections
] | each { |e| $"-Wl,($e)" }

print $"(ansi green)Building(ansi reset)"
print-and-run-cmd $CC ...$COMMON_FLAGS ...$CFLAGS ...[
	main.c
	-o $MAIN_OBJ_FILE
]

print $"(ansi green)Linking(ansi reset)"
print-and-run-cmd $LD ...$COMMON_FLAGS ...$LDFLAGS ...[
	$MAIN_OBJ_FILE
	-o $MAIN_ELF_FILE
]
