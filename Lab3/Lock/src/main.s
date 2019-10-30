	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	password: .byte 0b1001
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_PUDPR, 0x4800080c
	.equ GPIOC_IDR, 0x48000810
	.equ time, 2000000
main:
	bl GPIO_init
	B Loop
GPIO_init:
	//TODO: Initial LED GPIO pins as output
	// Enable AHB2 clock to control GPIOB(2)
	movs r0, 0b110
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]
	// set PB3, PB4, PB5, PB6 to output mode(1)
	movs r0, 0b01010101000000
	ldr r1, =GPIOB_MODER
	str r0, [r1]
	// set PB3, PB4, PB5, PB6 to high speed mode
	movs r0, 0b10101010000000
	ldr r1, =GPIOB_OSPEEDR
	str r0, [r1]
	// set the initial light right bulb
	ldr r0, =GPIOB_ODR
	movs r1, 0b11111111
	str r1, [r0]

	// set PC13 to input mode(0)
	ldr r0, =#0xF3FFFF00
	ldr r1, =GPIOC_MODER
	str r0, [r1]
	// set PC0~PC3 to Pull-up(01)
	movs r0, 0b01010101
	ldr r1, =GPIOC_PUDPR
	str r0, [r1]
	// set PC13 1
	movs r0, 0b10000000000000
	ldr r1, =GPIOC_IDR
	str r0, [r1]
	bx lr
Loop:
	bl Polling_User_Button
	bl Read_DIP_switch_value
	b Loop
Polling_User_Button:
	ldr r0, =GPIOC_IDR
	ldr r1, [r0]
	ands r1, r1, 0b10000000000000
	cmp r1, 0
	bne Polling_User_Button
	bx lr
Read_DIP_switch_value:
	ldr r0, =GPIOC_IDR
	ldr r1, [r0]
	and r1, r1, 0b1111
	eor r1, r1, 0b1111
	// compare password
	ldr r2, =password
	ldr r2, [r2]
	cmp r1, r2
	bne Blink1
	b Blink3
Blink1:
	ldr r0, =GPIOB_ODR
	movs r1, 0b10000111
	str r1, [r0]
	ldr r0, =time
	Loop2:
		subs r0, 5
		cmp r0, 0
		bge Loop2
	ldr r0, =GPIOB_ODR
	movs r1, 0b11111111
	str r1, [r0]
	bx lr
Blink3:
	movs r2, 0
	Loop3:
		ldr r0, =GPIOB_ODR
		movs r1, 0b10000111
		str r1, [r0]
		ldr r0, =time
		Loop4:
			subs r0, 5
			cmp r0, 0
			bge Loop4
		ldr r0, =GPIOB_ODR
		movs r1, 0b11111111
		str r1, [r0]
		ldr r0, =time
		Loop5:
			subs r0, 5
			cmp r0, 0
			bge Loop5
		adds r2, 1
		cmp r2, 3
		bne Loop3
	bx lr
