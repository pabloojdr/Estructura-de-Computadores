/* Escribe un programa, Ejer7.s que sondee si se ha pulsado el botón 1 (GPIO 2) o el
botón 2 (GPIO 3). En caso de que se haya pulsado el primero, se generará un sonido
correspondiente a la nota Do (262Hz). Si por el contrario se pulsa el segundo, se
generará un sonido correspondiente a la nota Sol (391Hz).*/

	.set GPBASE, 0x3F200000
	.set GPSEL0, 0x00
	.set GPSET0, 0x1c
	.set GPCLR0, 0x28
	.set GPLEV0, 0x34
	.set STBASE, 0x3F003000
	.set STCLO, 0x04

.text
	@Inicia el modo supervisor (Es necesario hacerlo siempre que queramos usar el timer)
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x08000000 
	
	ldr r0, =GPBASE
	
		 /*xx999888777666555444333222111000*/
	mov r1, #0b00000000000000000001000000000000
	str r1, [r0, #GPSEL0]					@configura el altavoz como salida
	mov r1, #0b00000000000000000000000000010000
	
	       /*xx10987654321098765432109876543210*/
	mov r2, #0b00000000000000000000000000000100	@mueve la posición del primer botón al registro r2
	mov r3, #0b00000000000000000000000000001000	@mueve la posición del segundo botón al registro r3
	
	ldr r8, =STBASE
	
	ldr r5, =1908							@mueve la nota do al registro r5
	ldr r6, =1278							@mueve la nota sol al registro r5
	
	
	
bucle:	ldr r4, [r0, #GPLEV0]				@GPLEV tiene guardados los valores a los que se encuentran los botones (pulsado o no pulsado)

		tst r2, r4						@compara si el primer botón está pulsado
		moveq r7, r5						@si está pulsado, salta y ejecuta el programa correspondiente
	
		tst r3, r4
		moveq r7, r6
		
		bl espera
		str r1, [r0, #GPSET0]
		bl espera
		str r1, [r0, #GPCLR0]
	
		b bucle

espera:	
	ldr r9, [r8, #STCLO]
	add r9, r7

ret:	ldr r10, [r8, #STCLO]
	cmp r10, r9
	blo ret								@si el tiempo es menor, vuelve a comprobar
	bx lr
	
infi: b infi