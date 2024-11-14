/*El nuevo código Ejer11.s, basado en el ejercicio anterior, hará parpadear los 6 leds uno
detrás de otro en secuencia, de tal manera que cada uno de ellos permanecerá
encendido 1seg. Cuando se alcance el led del extremo se volverá a empezar por el
primero, continuándose con la secuencia de encendidos y apagados de forma
indefinida.*/

.include "inter.inc"
	
.text
	mov r0, #0
	ADDEXC 0x18, irq_handler					@añadimos el vector interrupción
	
	mov r0, #0b11010010						@Activamos el modo IRQ
	msr cpsr_c, r0
	mov sp, #0x8000
	
	mov r0, #0b11010011						@Activamos el modo supervisor SVC
	msr cpsr_c, r0
	mov sp, #0x8000000
	
	ldr r0, =GPBASE
		  @xx999888777666555444333222111000
	mov r1, #0b00001000000000000000000000000000	@Configuramos GPIO09 como salida
	str r1, [r0, #GPFSEL0]
		  @xx999888777666555444333222111000
	ldr r1, =0b00000000001000000000000000001001	@Configuramos GPIO10, GPIO11 y GPIO17 como salida
	str r1, [r0, #GPFSEL1]
		  @xx999888777666555444333222111000
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]
	
	ldr r0, =STBASE						@programamos el contador C1 para una futura interrupción (guardamos el contador en C1(?)
	ldr r1, [r0, #STCLO]
	ldr r2, =1000000						@añadimos medio segundo
	add r1, r2
	str r1, [r0, #STC1]
	
	ldr r0, =INTBASE
	mov r1, #0b0010
	str r1, [r0, #INTENIRQ1]
	
	mov r0, #0b01010011
	msr cpsr_c, r0
	
bucle: b bucle

irq_handler:
	push {r0, r1, r2, r3}
	
	ldr r0, =STBASE
	ldr r1, =GPBASE
	
	ldr r2, =cuenta
	
	ldr r3, =0b00001000010000100000111000000000
	str r3, [r1, #GPCLR0]
	ldr r3, [r2]
	subs r3, #1
	moveq r3, #6
	str r3, [r2]
	ldr r3, [r2, +r3, LSL #2]
	str r3, [r1, #GPSET0]
	
	mov r3, #0b0010						@reseteo el estado de la interrupción
	str r3, [r0, #STCS]
	
	ldr r3, [r0, #STCLO]
	ldr r2, =1000000
	add r3, r2
	str r3, [r0, #STC1]
	
	ldr r3, [r0, #STCS]
	ands r3, #0b0100
	beq final
	
final:	pop {r0, r1, r2, r3}
		subs pc, lr, #4
	
cuenta:	.word 1
	      	  @7654321098765432109876543210
secuen: 	.word 0b1000000000000000000000000000
		.word 0b0000010000000000000000000000
		.word 0b0000000000100000000000000000
		.word 0b0000000000000000100000000000
		.word 0b0000000000000000010000000000
		.word 0b0000000000000000001000000000
