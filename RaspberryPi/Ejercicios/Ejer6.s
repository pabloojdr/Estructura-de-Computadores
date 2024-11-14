.set GPBASE, 0x3F200000
.set GPFSEL0, 0x00
.set GPSET0, 0x1c
.set GPCLR0, 0x28
.set STBASE, 0x3F003000
.set STCLO, 0x04

.text
@INICAR LA PILA EN MODO SUPERVISOR -- Hacer siempre que haya que usar el timer
mov r0, #0b11010011
msr cpsr_c, r0
mov sp, #0x08000000 


	ldr r4, =GPBASE
/* guia bits	   xx999888777666555444333222111000 */
@CONFIGURAMOS EL PRIMER LED ROJO
	mov r5, #0b00001000000000000000000000000000
	str r5, [r4, #GPFSEL0]
/* guia bits	   01987654321098765432109876543210 */	
	mov r5, #0b00000000000000000000001000000000

ldr r0, =STBASE
ldr r1, =1000000 @ 1s
ldr r2, =500000
ldr r3, = 250000 

bucle: 
	bl espera
	str r5, [r4, #GPSET0] @ ENCIENDE LED ROJO
	bl espera
	str r5, [r4, #GPCLR0] @APAGA LED ROJO
	bl espera1
	str r5, [r4, #GPSET0]
	bl espera1
	str r5, [r4, #GPCLR0]
	bl espera2 
	str r5, [r4, #GPSET0]
	bl espera2
	str r5, [r4, #GPCLR0]
	b bucle
espera: 
	push {r4,r5} 			@Guarda r4 y r5 en stack
	ldr r4, [r0, #STCLO]		@Carga el CLO timer
	add r4, r1			@Añade el waiting time al tiempo actual, es decir, da nuestro tiempo de finalizacion
ret1:	
	ldr r5, [r0, #STCLO]		@Carga en r5 el tiempo actual del timer
	cmp r5, r4			@Compara los tiempos
	blo ret1			@Si el tiempo es menor, vuelve a mirarlo
	pop {r4,r5}			
	bx lr
	
espera1: 
	push {r4,r5} 			@Guarda r4 y r5 en stack
	ldr r4, [r0, #STCLO]		@Carga el CLO timer
	add r4, r2			@Añade el waiting time al tiempo actual, es decir, da nuestro tiempo de finalizacion
ret2:	
	ldr r5, [r0, #STCLO]		@Carga en r5 el tiempo actual del timer
	cmp r5, r4			@Compara los tiempos
	blo ret2			@Si el tiempo es menor, vuelve a mirarlo
	pop {r4,r5}			
	bx lr
	
espera2: 
	push {r4,r5} 			@Guarda r4 y r5 en stack
	ldr r4, [r0, #STCLO]		@Carga el CLO timer
	add r4, r3			@Añade el waiting time al tiempo actual, es decir, da nuestro tiempo de finalizacion
ret3:	
	ldr r5, [r0, #STCLO]		@Carga en r5 el tiempo actual del timer
	cmp r5, r4			@Compara los tiempos
	blo ret3			@Si el tiempo es menor, vuelve a mirarlo
	pop {r4,r5}			
	bx lr

infi: b infi