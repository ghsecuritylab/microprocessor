#include "stm32l476xx.h"
#include "utility.h"

extern void gpio_init();
extern void test();

int Distance;

int main(void) {
	init_hx711();
	fpu_enable();
	gpio_init();
	timer_init();
	counter_init();
	//test(100, HCSR04GetDistance(), 10);
	//test(100, SW420Vibration(), 10);
	//test(100, VoiceDetection(), 100);
	//test(100, PressDetection(), 100);
	//timer_config(DO);
	//TIM2->CR1 |= TIM_CR1_CEN;

	while(1){
		//if(HCSR04GetDistance()<5) TIM2->CR1 &= ~TIM_CR1_CEN;
		//if(SW420Vibration()) TIM2->CR1 &= ~TIM_CR1_CEN;
		//if(PressDetection()) TIM2->CR1 &= ~TIM_CR1_CEN;
		test(100, PressDetection(), 100);
		/*if(VoiceDetection()){
			timer_config(RE);
			TIM2->CR1 |= TIM_CR1_CEN;
		}*/
	}
}


