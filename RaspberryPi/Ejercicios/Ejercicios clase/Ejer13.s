/*En este ejercicio vamos trabajar simultáneamente con las IRQs de los comparadores
C1 y C3 del timer. Con C1 controlaremos el encendido consecutivo de los 6 LEDs con
una cadencia de 200msg, de forma similar a lo que hicimos en Ejer11.s: el primer led
se enciende durante 200msg, pasados los cuales se apagará para encenderse el
siguiente LED, y así sucesivamente (cuando se apague el sexto, volvemos a empezar
con el primero). Con C3 controlaremos el altavoz para que se produzca un sonido con
una frecuencia de 440Hz. Inicialmente, el programa principal programará la
interrupción del timer para dentro de 200msg. La rutina de tratamiento de la IRQ, tras
determinar cuál de los dos comparadores ha provocado la interrupción, lo
reprogramará para que interrumpa con la periodicidad deseada.*/

.include "inter.inc"

.text
	ADDEXC 0x18, irq_handler
	
	mov r0, #0b11010010
	msr cpsr_c, r0
	mov sp, #0x8000
	
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000
	
	ldr r0, =GPBASE
		  @xx999888777666555444333222111000
	ldr r1, =0b00001000000000000001000000000000	@Configuramos GPIO09 como salida
	s
	
	ldr r0, =INTBASE
	mov r1, #0b1010
	str r1, [r0, #INTENIRQ1]
	mov r0, #0b01010011
	msr cpsr_c, r0
	
bucle: 	b bucle

irq_handler:
	push {r0,r1,r2,r3}
	
	ldr r0, =STBASE
	ldr r1, =GPBASE
	ldr r2, [r0, #STCS]
	ands r2, #0b0010						@comparamos haciendo un and con C1, si es C1 dará 1 y no saltará
	beq sonido
	
	ldr r2, =cuenta
	
	ldr r3, =0b00001000010000100000111000000000
	str r3, [r1, #GPCLR0]
	ldr r3, [r2]
	subs r3, #1
	moveq r3, #6
	str r3, [r2]
	ldr r3, [r2, +r3, LSL #2]
	str r3, [r1, #GPSET0]
	
	mov r3, #0b0010
	str r3, [r0, #STCS]
	
	ldr r3, [r0, #STCLO]
	ldr r2, =200000
	add r3, r2
	str r3, [r0, #STC1]
	
	ldr r3, [r0, #STCS]
	ands r3, #0b0100
	beq final
	
sonido:	ldr r2, =bitson
	ldr r3, [r2]
	eors r3, #1
	str r3, [r2]
	mov r3, #0b10000
	streq r3, [r1, #GPSET0]
	strne r3, [r1, #GPCLR0]
	
	mov r3, #0b1000
	str r3, [r0, #STCS]
	
	ldr r3, [r0, #STCLO]
	ldr r2, =1136
	add r3, r2
	str r3, [r0, #STC3]
	
final: 	pop {r0, r1, r2, r3}
	subs pc, lr, #4
	
bitson:	.word 0
cuenta:	.word 1
secuen:	.word 0b1000000000000000000000000000
	.word 0b0000010000000000000000000000
	.word 0b0000000000100000000000000000
	.word 0b0000000000000000100000000000
	.word 0b0000000000000000010000000000
	.word 0b0000000000000000001000000000

	