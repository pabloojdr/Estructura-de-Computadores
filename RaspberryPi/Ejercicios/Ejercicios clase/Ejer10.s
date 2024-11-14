/* El nuevo código Ejer10.s, basado en el ejercicio anterior, hará parpadear los 6 leds
simultáneamente.*/

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
	ldr r2, =500000						@añadimos medio segundo
	add r1, r2
	str r1, [r0, #STC1]
	
	ldr r0, =INTBASE
	mov r1, #0b0010
	str r1, [r0, #INTENIRQ1]
	
	mov r0, #0b01010011
	msr cpsr_c, r1
	
bucle: b bucle

irq_handler: 
	push {r0, r1, r2}
	
	ldr r0, =ledst							@Leemos el puntero a vector ledst
	ldr r1, [r0]							@Leemos la variable
	
	eors r1, #1							@Invertimmos bit 0 y activamos la flag Z
	str r1, [r0]							@Escribimos la variable para saber si está encendido o apagado e ir trabajando en fución de lo último que se hizo
	
	ldr r0, =GPBASE
		  @01987654321098765432109876543210
	ldr r1, =0b00001000010000100000111000000000
	streq r1, [r0, #GPSET0]					@Encendemos el led en función de Z
	strne r1, [r0, #GPCLR0]					@Apagamos el led en función de Z
	
	
	ldr r0, =STBASE
	mov r1, #0b0010
	str r1, [r0, #STCS]						@Reseteamos el estado de interrupción de C1
	
	ldr r1, [r0, #STCLO]
	ldr r2, =500000
	add r1, r2
	str r1, [r0, #STC1]						@Volvemos a programar la interrupción medio segundo después
	
	pop {r0, r1, r2}
	subs pc, lr, #4
	
ledst:	.word 0
	
	