#!/usr/bin/env nu

use utils.nu print-and-run-cmd
const HERE = path self .

def main [
	toolchain
	--board = "xplainedpro"
	--mcu = "atmega324pb"
] {
	let build_dir = $HERE | path join $"build-($toolchain)"
	let elf = $build_dir | path join "main.elf"
	let hex = $build_dir | path join "main.hex"

	print $"(ansi green)Creating hex(ansi reset)"
	print-and-run-cmd avr-objcopy -O ihex -R .eeprom $elf $hex
	print $"(ansi green)Flashing(ansi reset)"
	print-and-run-cmd avrdude -F -V -c $board -p $mcu -U flash:w:($hex)

}
