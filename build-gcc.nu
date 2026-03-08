#!/usr/bin/env nu


const OUTPUT_DIR = path self ./build-gcc/
const MAIN_OBJ_FILE = $OUTPUT_DIR | path join main.o
const MAIN_ELF_FILE = $OUTPUT_DIR | path join main.elf

# Target microcontroller
const MCU = "atmega328p"

# Clock frequency (16MHz for Arduino Uno)
const F_CPU = "16000000UL"

# Compiler and tools
const CC = "avr-gcc"

# Compiler flags
let CFLAGS = [
	-mmcu=($MCU)
	-DF_CPU=($F_CPU)
	-Os
	-Wall
	-Wextra
	-std=c99
	-D__DELAY_BACKWARD_COMPATIBLE__ # Not really needed but to better match clang build for comparison
]

# Linker flags
let LDFLAGS = [
	--gc-sections
] | each { |e| $"-Wl,($e)" }

print $"(ansi green)Building(ansi reset)"
^$CC -v ...$CFLAGS ...[
	-g
	-ffunction-sections
	-fdata-sections
	-c
	main.c
	-o $MAIN_OBJ_FILE
]

print $"(ansi green)Linking(ansi reset)"
^$CC -v ...$CFLAGS ...$LDFLAGS ...[
	$MAIN_OBJ_FILE
	-o $MAIN_ELF_FILE
]
