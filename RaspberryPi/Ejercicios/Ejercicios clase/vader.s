/*
En cuanto se cargue el programa empezará a sonar una conocida melodía. Las notas
que la componen se os proporcionan en el fichero “vader.inc”, que a su vez utiliza
constantes que se definen en el “notas.inc”. Tu fichero fuente, al que deberás
renombrar con tu DNI antes de la entrega, los debe incluir en el orden correcto.
Adicionalmente, los 6 leds de la placa deberán cambiar su patrón de encendido al
ritmo de la melodía. Cuál es el patrón activo estará controlado por la pulsación de los
botones de la placa. Al menos deberás programar dos patrones de encendido,
asociados a cada uno de los dos botones. Un patrón consistirá en el encendido y
apagado simultáneo de los 6 leds, y el otro en el encendido en secuencia de cada uno
de ellos, de forma similar a ejercicios previos (Ejer10 y Ejer11). 
*/
	.include "inter.inc"
	.include "notas.inc"
	.include "vader.inc"

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
	@	      99988777666555444333222111000
	ldr r1, =0b00001000000000000001000000000000
	str r1, [r0, #GPFSEL0]  	 @GPIO9, GPIO4 (altavoz)
	ldr r1, =0b00000000001000000000000000001001
	str r1, [ r0, # GPFSEL1 ]	@GPIO10, GPIO11, GPIO17
	ldr r1, =0b00000000001000000000000001000000
	str r1, [ r0, # GPFSEL2 ]	@GPIO22, GPIO27
	
	
@ 5. CONFIGURAMOS C1 Y C3 PARA DENTRO DE 2 MICROSEGUNDOS
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, #2
	str r1, [r0, #STC1] 	@C1
	str r1, [r0, #STC3]	@C3
	
@ 6. INCIALIZAMOS LAS INTERRUPCIONES LOCALMENTE

@ 6.1. HABILITAMOS C1 PARA IRQ
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

@ cuando se pulse un boton se guarda en la variable estado 2 o 3 dependiendo del boton pulsado
bucle:

	ldr r0, =GPBASE
@ COMPROBAMOS PULSACIONN BOTON GPIO2
	ldr r3, [r0, #GPLEV0]
	mov r2, #0b000000100
	ands r3, r2
	beq boton2
	
@ COMPROBAMOS PULSACION BOTON GPIO3
	ldr r3, [r0, #GPLEV0]
	mov r2, #0b000001000
	ands r3, r2
	beq boton3

	b bucle

boton2:
@ SI EL BOTON GPIO2 ES PULSADO, GUARDAMOS EN ESTADOBOTON UN 2
	ldr r3, =estadoboton
	mov r4, #2
	str r4, [r3]
	b bucle

boton3:
@ SI EL BOTON GPIO3 ES PULSADO, GUARDAMOS EN ESTADOBOTON UN 3
	ldr r3, =estadoboton
	mov r4, #3
	str r4, [r3]
	b bucle

@-----------------------------------------------------------------------------------------------
irq_handler:
	push   {r0, r1, r2, r3,r4,r5,r6}
	
	ldr r0, =estadoboton
	ldr r1, [r0]
	cmp r1, #2		@ comprobamos si el bot�n pulsado es el 2
	beq secuen		@ 2 = encendido de leds uno tras otro
	b parpadeo		@ 3 = encendido simultaneo

@-----------------------------------------------------------------------------------------------
secuen:

	ldr r0, =GPBASE
	ldr r1, =cuentaleds


	@APAGAMOS TODOS LOS LEDS
	@	   10987654321098765432109876543210
	ldr r2, =0b00001000010000100000111000000000
	str r2, [r0, #GPCLR0]
	
@ es distinto al usual porque cuentaleds empezamos a contar desde 0, y no desde 1

	ldr r2, [r1] 				@ Leo variable cuentaleds
	subs r2, #1 				@ Decremento
	cmp r2, #-1
	moveq r2, #5			 	@ Si es 0, volver a 6
	str r2, [r1]				@ Escribo cuenta
	
	
	ldr r1, =secuen_led
	ldr r2, [r1, +r2, LSL #2] 		@ Leo secuencia
	str r2, [r0, #GPSET0] 			@ Escribo secuencia en LEDs


	b notas
	
@-----------------------------------------------------------------------------------------------
parpadeo:

@Vemos el estado del led, guardado en encendidoled
	ldr r3, =encendidoled
@ invierto estado de encendidoLED
	ldr r1, [r3]
	eors r1, #1
	str r1, [r3]
	
	ldr r0, =GPBASE

	@APAGAMOS TODOS LOS LEDS
	@	   10987654321098765432109876543210
	ldr r1, =0b00001000010000100000111000000000
	streq r1, [r0, #GPSET0] 
	strne r1, [r0, #GPCLR0]
	
	b notas

	
@-----------------------------------------------------------------------------------------------

notas:

	ldr r5, =duratFS  		@ carga array duracion
	ldr r2, =contador_notas  	@ Puntero array duracionFS y notasFS
	
	ldr r3, [r2]
	add r3, #1  			@ aumentamos el puntuero auxiliar
	cmp r3, #NUMNOTAS
	moveq r3, #0   			@ Si llega al fin del array lo pone a 0
	str r3, [r2]
	
	ldr r6, [r5, r3, LSL #2] 	@ --> guardamos en r6 la duraci�n de la nota

	b continua
	

@--------------------------------------------------------------------------------------------

continua:
/* Reseteo estado interrupcion de C1 */
	ldr r0, =STBASE
	mov r2, #0b0010
	str r2, [r0, #STCS]
	
/* Programo siguiente interrupcIon lo que dura la nota */
	ldr r4, [r0, #STCLO]
	add r4, r6		@ duracion de la nota
	str r4, [r0, #STC1]


/* RECUPERO REGISTROS Y SALGO*/
	pop    {r0, r1, r2, r3,r4,r5,r6}
	subs   pc, lr, #4

	
@-----------------------------------------------------------------------------------------------
fiq_handler:

@ REGISTROS QUE PODEMOS USAR SIN PREOCUPARNOS: 8-13
	ldr r8, =GPBASE 
	ldr r9, =bitson 	
	ldr r11, =contador_notas
	
@LEEMOS SECUENCIA SONIDOS --> guardamos valor en r12
	ldr r12, [r11]			@ Leo variable contador_notas
	ldr r11, =notaFS	
	ldr r12, [r11, +r12, LSL #2]	@ Leo secuencia
	@guardamos en r12 la frecuencia de cada nota
	
@INVIERTIENDO EL ESTADO DEL BITSON
	ldr r10, [r9]
	eors r10, #1
	str r10, [r9]
	
@PONGO ESTADO ALTAVOZ SEG�N VARIABLE DEL BITSON
	ldr r10, =0b10000 		@GPIO4 - altavoz
	streq r10, [r8, #GPSET0]	@enciendo
	strne r10, [r8, #GPCLR0]	@apago
	
cont:	
@ Reseteo estado interrupci�n de C3 
	ldr r8, =STBASE
	mov r10, #0b1000
	str r10, [r8, #STCS]
	
@ Programo siguiente retardo seg�n valor le�do en array
	ldr r10, [r8, #STCLO]
	add r10, r12			@ r12 el valor leido en el array --> frecuencia de la nota que se debe tocar 		
	str r10, [r8, #STC3]

@PROGRAMO SIGUIENTE INTERRUPCI�N EN 500ms
	ldr r2, [r0, #STCLO]
	ldr r1, =500000 		@ 2 Hz
	add r2, r1
	str r2, [r0, #STC1]
	
subs pc, lr, #4


encendidoled: .word 0
estadoboton: .word 3			@ iniciamos con el parpadeo de los leds
bitson: .word 0
contador_notas: .word 0

cuentaleds: .word 1
secuen_led:
.word 0b1000000000000000000000000000		
.word 0b0000010000000000000000000000		
.word 0b0000000000100000000000000000	
.word 0b0000000000000000100000000000		
.word 0b0000000000000000010000000000		
.word 0b0000000000000000001000000000	



