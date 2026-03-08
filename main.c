
#include <avr/io.h>
#include <util/delay.h>

#define LED_PIN PB5  // Pin 13 on Arduino Uno (built-in LED)

int main(void) {
	// Set LED pin as output
	DDRB |= (1 << LED_PIN);

	while (1) {
		// Turn LED on
		PORTB |= (1 << LED_PIN);
		_delay_ms(500);

		// Turn LED off
		PORTB &= ~(1 << LED_PIN);
		_delay_ms(500);
	}

	while (1) {};

	return 0;
}
