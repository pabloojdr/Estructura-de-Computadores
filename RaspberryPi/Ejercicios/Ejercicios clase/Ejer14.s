/*Este ejercicio es similar al anterior pero el encendido de cada LED tendrá asociado un
sonido simultáneo distinto. Para ello ahora vamos a utilizar además de la IRQ, una FIQ,
de manera que las rutinas de tratamiento serán independientes. C1, que controla el
encendido sucesivo de los 6 LEDs, interrumpirá con una IRQ, mientras que C3, que
controla el altavoz, lo hará con una FIQ. Le damos más prioridad a C3 porque es la
interrupción que se va a producir con más frecuencia. Los LEDs se mantendrán
encendidos durante 500msg La secuencia de notas que sonará será: Re Re Mi Re Sol
Fa# Re Re Mi Re La Sol Re Re Re' Si Sol Fa# Mi Do' Do' Si Sol La Sol*/


.include "inter.inc"

.text
@ 1 . INICIALIZAMOS LA TABLA DE VECTORES
	mov    r0, #0
	ADDEXC 0x18, irq_handler
	ADDEXC 0x1C, fiq_handler
	
@ 2.1 . INICIAMOS LA PILA EN MODO FIQ
	mov r0, #0b11010001
	msr cpsr_c, r0			@ FIQ mode, init stack
	mov sp, #0x4000

@ 2.2 . INCIAMOS LA PILA EN MODO IRQ

	mov     r0, #0b11010010   
	msr     cpsr_c, r0		@ IRQ mode, init stack
	mov     sp, #0x8000

@ 3 . INCIAMOS LA PILA EN MODO SUPERVISOR

	mov     r0, #0b11010011
	msr     cpsr_c, r0		@ SVC mode, init stack
	mov     sp, #0x8000000
	
@ 4. HACEMOS LAS CONFIGURACIONES DE GPIO PERTINENTES

	ldr    r0, =GPBASE
	@	             99988777666555444333222111000
	ldr r1, =0b00001000000000000001000000000000
	str r1, [r0, #GPFSEL0]  	 @GPIO9, GPIO4 
	ldr r1, =0b00000000001000000000000000001001
	str r1, [ r0, # GPFSEL1 ]	@GPIO10, GPIO11, GPIO17
	ldr r1, =0b00000000001000000000000001000000
	str r1, [ r0, # GPFSEL2 ]	@GPIO22, GPIO27
	
@ 5. CONFIGURAMOS C1 Y C3 PARA DENTRO DE 2 MICROSEGUNDOS
	ldr r0, =STBASE

	ldr r1, [r0, #STCLO]
	add r1, #0x4000		@2microsegundos en hexadecimal, idkw
	str r1, [r0, #STC1] 	@C1
	
	ldr r1, [r0, #STCLO]
	add r1, #0x4000
	str r1, [r0, #STC3]	@C3
	
@ 6. INCIALIZAMOS LAS INTERRUPCIONES LOCALMENTE

@ 6.1. HABILITAMSO C1 PARA IRQ
	ldr    r0, =INTBASE         @ Enable interrupt at C1
	mov r1, #0b0010
	str r1, [r0, #INTENIRQ1]
	
@ 6.2. HABILITAMOS C3 PARA FIQ
	ldr    r0, =INTBASE 
	mov r1, #0b10000011
	str r1, [r0, #INTFIQCON]
	
@ 7. HABILITAMOS INTERRUPCIONES GLOBALMENTE -- IRQ Y FIQ
	
	mov    r0, #0b00010011      @ SVC mode, IRQ and FIQ enabled
	msr    cpsr_c, r0

@ 8. RESTO DE PROGRAMA PRINCIPAL

buc:	b      buc


irq_handler:
	push   {r0, r1, r2, r11, r12}
	
	ldr r0, =GPBASE
	ldr r1, =cuenta
	ldr r11, =cuenta2

@APAGAMOS TODOS LOS LEDS
	@	   	10987654321098765432109876543210
	ldr r2, =0b00001000010000100000111000000000
	str r2, [r0, #GPCLR0]

@ESCRIBIMOS EN CUENTA EL VALOR DEL LED QUE DEBE TOMAR
	ldr r2, [r1] 				@ Leo variable cuenta	
	subs r2, #1 				@ Decremento	
	moveq r2, #6			 	@ Si es 0, volver a 6
	str r2, [r1]				@ Escribo cuenta

@ESCRIBIMOS EN CUENTA2 EL VALOR QUE DEBE SER
	ldr r12, [r11]
	subs r12, #1
	moveq r12, #25
	str r12, [r11]
	
@LEEMSO SECUENCIA LEDS Y LA VAMOS ENCENDIENDO
	ldr r2, [r1, +r2, LSL #2] 		@ Leo secuencia		
	str r2, [r0, #GPSET0] 			@ Escribo secuencia en LEDs
	
		
@RESETEO INTERRUPCIÓN C1
	ldr r0, =STBASE
	mov r2, #0b0010
	str r2, [r0, #STCS]
	
@ PROGRAMO SIGUIENTE INTERRUPCIÓN EN 500MS	
	ldr r2, [r0, #STCLO]
	ldr r1, =500000 		@ 2 Hz
	add r2, r1
	str r2, [r0, #STC1]

@ RECUPERO REGISTROS Y SALGO
	pop    {r0, r1, r2, r11, r12}
	subs   pc, lr, #4



fiq_handler:

@ REGISTROS QUE PODEMOS USAR SIN PREOCUPARNOS: 8-13
	ldr r8, =GPBASE 
	ldr r9, =bitson 	
	ldr r11, =cuenta2
	
@LEEMOS SECUENCIA SONIDOS --> guardamos valor en r12	
	ldr r12, [r11]			@ Leo variable cuenta2	
	ldr r12, [r11, +r12, LSL #2]	@ Leo secuencia
	
@HACEMOS SONAR EL ALTAVOZ INVIERTIENDO EL ESTADO DEL BITSON
	ldr r10, [r9]
	eors r10, #1
	str r10, [r9]
	
@PONGO ESTADO ALTAVOZ SEGÚN VARIABLE DEL BITSON
	ldr r10, =0b10000 		@GPIO4 - altavoz
	streq r10, [r8, #GPSET0]	@enciendo
	strne r10, [r8, #GPCLR0]	@apago
	
@ Reseteo estado interrupción de C3 
	ldr r8, =STBASE
	mov r10, #0b1000
	str r10, [r8, #STCS]
	
@ Programo siguiente retardo según valor leído en array
	ldr r10, [r8, #STCLO]
	add r10, r12		@ r12 el valor leido en el array 		
	str r10, [r8, #STC3]

@PROGRAMO SIGUIENTE ITERRUPCIÓN EN 500ms
	ldr r2, [r0, #STCLO]
	ldr r1, =500000 		@ 2 Hz
	add r2, r1
	str r2, [r0, #STC1]
	

subs pc, lr, #4
	

bitson: .word 0					@ Bit 0 = Estado de altazon
cuenta: .word  1				@ Entre 1 y 6, LED a encender
secuen: 
.word 0b1000000000000000000000000000		
.word 0b0000010000000000000000000000		
.word 0b0000000000100000000000000000	
.word 0b0000000000000000100000000000		
.word 0b0000000000000000010000000000		
.word 0b0000000000000000001000000000	

cuenta2: .word  1				@ Entre 1 y 25, MELODIA ALTAVOZ
frec:
.word 1275  @SOL
.word 1136  @LA	
.word 1275  @SOL		
.word 1012  @SI		
.word 956   @DO			
.word 956   @DO			
.word 1515  @MI			
.word 1351  @FA		
.word 1275  @SOL		
.word 1012  @SI		
.word 851   @RE'			
.word 1706  @RE			
.word 1706  @RE		
.word 1275  @SOL		
.word 1136  @LA		
.word 1706  @RE			
.word 1515  @MI				
.word 1706  @RE			
.word 1706  @RE		
.word 1351  @FA			
.word 1275  @SOL			
.word 1706  @RE		
.word 1515  @MI			
.word 1706  @RE			
.word 1706  @RE



@Hz -> micros ==> (1/Hz)/2 * 10^6
	
	
	
	
	
	