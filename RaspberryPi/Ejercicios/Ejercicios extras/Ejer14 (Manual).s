.include "inter.inc"

.text
	ADDEXC 0x18, irq_handler
	ADDEXC 0x1c, fiq_handler
	
	mov r0, #0b11010001
	msr cpsr_c, r0
	mov sp, #0x400
	
	mov r0, #0b11010010
	msr cpsr_c, r0
	mov sp, #0x8000
	
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000
	
	ldr r0, =GPBASE
	ldr r1, =0b00001000000000000001000000000000
	str r1, [r0, #GPFSEL0]
		  @xx999888777666555444333222111000
	ldr r1, =0b00000000001000000000000000001001	@Configuramos GPIO10, GPIO11 y GPIO17 como salida
	str r1, [r0, #GPFSEL1]
		  @xx999888777666555444333222111000
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]
	
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, #2
	str r1, [r0, #STC1]
	str r1, [r0, #STC3]
	
	ldr r0, =INTBASE
	mov r1, #0b0010
	str r1, [r0, #INTENIRQ1]
	
	mov r1, #0b10000011
	str r1, [r0, #INTFIQCON]
	
	mov r0, #0b00010011
	msr cpsr_c, r0
	
bucle: 	b bucle

irq_handler:
	push {r0, r1, r2}
	ldr r0, =GPBASE
	ldr r1, =cuenta
	
		  @10987654321098765432109876543210
	ldr r2, =0b00001000010000100000111000000000
	str r2, [r0, #GPCLR0]
	ldr r2, [r1]
	subs r2, #1
	moveq r2, #6
	str r2, [r1], #-4
	ldr r2, [r1, +r2, LSL #3]
	str r2, [r0, #GPSET0]
	
	ldr r0, =STBASE
	mov r2, #0b0010
	str r2, [r0, #STCS]
	
	ldr r2, [r0, #STCLO]
	ldr r1, =500000
	add r2, r1
	str r2, [r0, #STC1]
	
	pop {r0, r1, r2}
	subs pc, lr, #4
	

fiq_handler:
	ldr r8, =GPBASE
	ldr r9, =bitson
	
	ldr r10, [r9]
	eors r10, #1
	str r10, [r9], #4
	
	ldr r10, [r9]
	ldr r9, [r9, +r10, LSL #3]
	
	mov r10, #0b10000
	streq r10, [r8, #GPSET0]
	strne r10, [r8, #GPCLR0]
	
	ldr r8, =STBASE
	mov r10, #0b1000
	str r10, [r8, #STCS]
	
	ldr r10, [r8, #STCLO]
	add r10, r9
	str r10, [r8, #STC3]
	
	subs pc, lr, #4
	
bitson:	.word 0
cuenta:	.word 1
	       @7654321098765432109876543210
secuen:	.word 0b1000000000000000000000000000
	.word 716
	.word 0b0000010000000000000000000000
	.word 758
	.word 0b0000000000100000000000000000
	.word 851
	.word 0b0000000000000000100000000000
	.word 956
	.word 0b0000000000000000010000000000
	.word 1012
	.word 0b0000000000000000001000000000
	.word 1136