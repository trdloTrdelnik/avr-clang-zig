
#include <avr/io.h>
#include <util/delay.h>

#define LED_PIN PC7  // Led pin on ATmega324pb Xplained Pro

int main(void) {
	// Set LED pin as output
	DDRC |= (1 << LED_PIN);

	while (1) {
		// Turn LED on
		PORTC |= (1 << LED_PIN);
		_delay_ms(100);

		// Turn LED off
		PORTC &= ~(1 << LED_PIN);
		_delay_ms(3000);
	}

	return 0;
}
