#include "stm32l476xx.h"
#include "utility.h"

extern void gpio_init();
extern void test();

int Distance;

int main(void) {
	gpio_init();
	counter_init();
	//test(100, HCSR04GetDistance(), 10);
	//test(100, SW420Vibration(), 10);
	//test(100, VoiceDetection(), 100);
}


