	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 8, 1, 0, 6, 1, 6, 0
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_ODR, 0x48000014
	.equ MAX7219_DIN, 0b00100000
	.equ MAX7219_CS, 0b01000000
	.equ MAX7219_CLK, 0b10000000
	.equ BSRR, 0x48000018
	.equ BRR, 0x48000028
main:
	bl GPIO_init
	// let r2~r6 to the correspond address
 	ldr r2, =MAX7219_DIN
	ldr r3, =MAX7219_CS
	ldr r4, =MAX7219_CLK
	ldr r5, =BSRR
	ldr r6, =BRR
	bl max7219_init
	bl Display_Number
All_Done:
	b All_Done

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs r0, 0b01
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	ldr r1, =GPIOA_MODER
	ldr r0, [r1]
	and r0, 0b11111111111111110000001111111111
	orr r0, 0b00000000000000000101010000000000
	str r0, [r1]

	movs r0, 0b1010100000000000
	ldr r1, =GPIOA_OSPEEDR
	str r0, [r1]

	movs r0, 0
	ldr r1, =GPIOA_ODR
	str r0, [r1]
	bx lr
Display_Number:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one	per second.
	push {lr}
	// r8 count from 0 to 7 because student number has 7
	movs r8, 0
	Display_Number_Loop:
		// r0 is digit0, r1 is data from arr
		ldr r1, =arr
		adds r1, r1, r8
		ldrb r1, [r1]
		adds r0, r8, 0b0001
		lsl r0, r0, 8

		movs r7, 0b1000000000000000
		adds r0, r0, r1
		bl Loop16
		adds r8, r8, 1
		// check whether 0xF
		cmp r8, 7
		blt Display_Number_Loop
	pop {lr}
	bx lr
MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {lr}
	adds r0, r0, r1
	movs r7, 0b1000000000000000
	bl Loop16
	pop {lr}
	bx lr
Loop16:
	// set the clock to 0
	str r4, [r6]
	// check r7 bit is 0 or 1 and then set DIN
	tst r0, r7
	beq Clear
	str r2, [r5]
	b Done
	Clear:
		str r2, [r6]
	Done:
		// set the clock to 1
		lsr r7, r7, 1
		str r4, [r5]
		// check if all 16 bits are in and set CS from 0 to 1
		cmp r7, 0
		bne Loop16
		str r3, [r6]
		str r3, [r5]
	bx lr
max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}
	// Decode Mode
	movs r0, 0b100100000000
	movs r1, 0xff
	bl MAX7219Send
	// Intensity
	movs r0, 0b101000000000
	movs r1, 0b1111
	bl MAX7219Send
	// Scan Limit
	movs r0, 0b101100000000
	movs r1, 0b110
	bl MAX7219Send
	// Shutdown
	movs r0, 0b110000000000
	movs r1, 1
	bl MAX7219Send
	// Display Test
	movs r0, 0b111100000000
	movs r1, 0
	bl MAX7219Send

	pop {lr}
	bx lr
