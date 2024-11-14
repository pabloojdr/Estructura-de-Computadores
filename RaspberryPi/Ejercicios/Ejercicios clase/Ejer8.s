/* Crea un nuevo programa, Ejer8.s, que configure el comparador C1 del timer para que
transcurridos 4 segundos se produzca una IRQ cuya rutina de servicio encienda el
LED asociado al GPIO 9. */

.include "inter.inc"

.text
	mov r0, #0				@iniciamos el vector interruptor
	ADDEXC 0x18, irq_handler
	
	mov r0, #0b11010010			@iniciamos el modo IRQ
	msr cpsr_c, r0
	mov sp, #0x8000
	
	mov r0, #0b11010011			@iniciamos el modo SVC
	msr cpsr_c, r0
	mov sp, #0x8000000
	
	ldr r0, =GPBASE			@configuramos GPIO9 como salida
		  @xx999888777666555444333222111000
	mov r1, #0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0]
	
	ldr r0, =STBASE			@programamos el contador C1 para una futura interrupción (guardamos el contador en C1(?)
	ldr r1, [r0, #STCLO]	
	ldr r1, =4000000			@añadimos aproximádamente 4s
	str r1, [r0, #STC1]
	
	ldr r0, =INTBASE			@habilitamos la interrupción por el comparador C1
	mov r1, #0b0010
	str r1, [r0, #INTENIRQ1]
	
	mov r0, #0b01010011			@inciamos el modo supervisor
	msr cpsr_c, r1
	
bucle: 	b bucle				@siempre el main tiene que acabar con un bucle infinito

irq_handler:				
	push {r0,r1}
	
	ldr r0, =GPBASE
	          @01987654321098765432109876543210
	mov r1, #0b00000000000000000000001000000000
	
	str r1, [r0, #GPSET0]		@enciendo el led
	
	pop {r0,r1}
	subs pc, lr, #4
	
	
	
	
	
	
	