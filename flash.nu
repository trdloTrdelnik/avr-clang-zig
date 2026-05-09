#!/usr/bin/env nu

const HERE = path self .

def main [
	toolchain
	--board = "xplainedpro"
	--mcu = "atmega324pb"
] {
	let build_dir = $HERE | path join $"build-($toolchain)"
	let elf = $build_dir | path join "main.elf"
	let hex = $build_dir | path join "main.hex"

	avr-objcopy -O ihex -R .eeprom $elf $hex
	avrdude -F -V -c $board -p $mcu -U flash:w:($hex)

}
