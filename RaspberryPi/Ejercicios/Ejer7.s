.set GPBASE, 0x3F200000
.set GPFSEL0, 0x00
.set GPSET0, 0x1c
.set GPCLR0, 0x28
.set STBASE, 0x3F003000
.set STCLO, 0x04
.set GPLEV0, 0x34

.text
@INICAR LA PILA EN MODO SUPERVISOR -- Hacer siempre que haya que usar el timer
mov r0, #0b11010011
msr cpsr_c, r0
mov sp, #0x08000000 


	ldr r4, =GPBASE

@ Botones
/* guia bits	   01987654321098765432109876543210 */	
        mov r2, #0b00000000000000000000000000000100
        mov r3, #0b00000000000000000000000000001000
@Altavoz
/* guia bits	   xx999888777666555444333222111000 */
	mov r5, #0b00000000000000000001000000000000
	str r5, [r4, #GPFSEL0]
/* guia bits	   01987654321098765432109876543210 */	
	mov r5, #0b00000000000000000000000000010000

ldr r0, =STBASE

ldr r6, =1908 @ DO
ldr r7, =1278 @ SOL


bucleSonido:

	ldr r9, [r4, #GPLEV0]
	
	tst r9, r2 	@primer boton
	moveq r10, r6 	@do

	tst r9, r3 	@segundo boton
	moveq r10, r7 	@sol
	
	bl espera
	str r5, [r4, #GPSET0] @ ENCIENDE ALTAVOZ
	bl espera
	str r5, [r4, #GPCLR0] @APAGA ALTAVOZ
	
	
	b bucleSonido


espera: 
	push {r4,r5} 			@Guarda r4 y r5 en stack
	ldr r4, [r0, #STCLO]		@Carga el CLO timer
	add r4, r10			@Añade el waiting time al tiempo actual, es decir, da nuestro tiempo de finalizacion
ret1:	
	ldr r5, [r0, #STCLO]		@Carga en r5 el tiempo actual del timer
	cmp r5, r4			@Compara los tiempos
	blo ret1			@Si el tiempo es menor, vuelve a mirarlo
	pop {r4,r5}			
	bx lr

infi: b infi