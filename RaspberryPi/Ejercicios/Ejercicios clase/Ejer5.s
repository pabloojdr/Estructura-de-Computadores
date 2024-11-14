/* Modifica Ejer4.s para que en vez de actuar sobre el led, genere un tono de 440Hz
(nota La) en el altavoz, generando para ello una onda cuadrada (serie de ceros y unos
consecutivos de idéntica duración) sobre el GPIO 4 y llama al programa Ejer5.s.*/

	.set GPBASE, 0x3F200000
	.set GPSEL0, 0x00
	.set GPSET0, 0x1c
	.set GPCLR0, 0x28
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
	str r1, [r0, #GPSEL0] 	@configura el altavoz como salida
	
	       /*xx10987654321098765432109876543210*/
	mov r1, #0b00000000000000000000000000010000
	
	ldr r2, =STBASE
	
bucle: 	bl espera				@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPSET0]	@enciende el altavoz
		bl espera				@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPCLR0]	@apaga el altavoz
		b bucle				@repite de nuevo todo el bucle para que se quede sonando
	
espera:	ldr r3, [r2, #STCLO]	@establece el contador en r3
		ldr r4, =1136			@carga en r4 la nota que queremos hacer sonar
	
		add r4, r3			@como el contador tendrá un valor, almacenamos en r4 dicho valor más la nota

ret1:	ldr r3, [r2, #STCLO]	@actualizamos el contador con el tiempo que va transcurriendo
		cmp r3, r4			@comparamos el tiempo actual, r3, con el tiempo al que queremos llegar r4
		bne ret1				@si el tiempo no es igual, saltamos de nuevo a la función ret1 hasta que haya pasado el tiempo deseado
		bx lr				@una vez pasado el tiempo volvemos a la siguiente linea desde donde ha saltado al bucle espera

infi: b infi