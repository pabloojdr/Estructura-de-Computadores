/*Modifica Ejer4.s para que el LED pase por una cadencia de 1 seg., luego 500 ms y
seguidamente 250 ms., y vuelve a repetir esta secuencia de cadencias de manera
indefinida. El tiempo que se tarda en pasar de una cadencia a otra puede ser el que
quieras, siempre que sea suficiente para apreciar el efecto. Llama al ejercicio Ejer6.s*/

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
	mov r1, #0b00001000000000000000000000000000
	str r1, [r0, #GPSEL0] 		@configura el led como salida
	
	       /*xx10987654321098765432109876543210*/
	mov r1, #0b00000000000000000000001000000000
	
	ldr r2, =STBASE
	
bucle: 	bl espera				@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPSET0]	@enciende el led
		bl espera				@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPCLR0]	@apaga el led
	
		bl espera1			@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPSET0]	@enciende el led
		bl espera1			@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPCLR0]	@apaga el led
	
		bl espera2			@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPSET0]	@enciende el led
		bl espera2			@espera el tiempo determinado dentro de esta función
		str r1, [r0, #GPCLR0]	@apaga el led
		
		b bucle				@repite de nuevo todo el bucle para que se quede sonando
	
espera:	ldr r3, [r2, #STCLO]	@establece el contador en r3
		ldr r4, =1000000		@carga en r4 el tiempo que deseamos que transcurra
	
		add r4, r3			@como el contador tendrá un valor, almacenamos en r4 dicho valor más el tiempo que queremos que transcurra

ret1:	ldr r3, [r2, #STCLO]	@actualizamos el contador con el tiempo que va transcurriendo
		cmp r3, r4			@comparamos el tiempo actual, r3, con el tiempo al que queremos llegar r4
		bne ret1				@si el tiempo no es igual, saltamos de nuevo a la función ret1 hasta que haya pasado el tiempo deseado
		bx lr				@una vez pasado el tiempo volvemos a la siguiente linea desde donde ha saltado al bucle espera
	
espera1:	ldr r3, [r2, #STCLO]	@establece el contador en r3
		ldr r4, =500000		@carga en r4 el tiempo que deseamos que transcurra
	
		add r4, r3			@como el contador tendrá un valor, almacenamos en r4 dicho valor más el tiempo que queremos que transcurra

ret2:	ldr r3, [r2, #STCLO]	@actualizamos el contador con el tiempo que va transcurriendo
		cmp r3, r4			@comparamos el tiempo actual, r3, con el tiempo al que queremos llegar r4
		bne ret2				@si el tiempo no es igual, saltamos de nuevo a la función ret2 hasta que haya pasado el tiempo deseado
		bx lr	
	
espera2:	ldr r3, [r2, #STCLO]	@establece el contador en r3
		ldr r4, =250000		@carga en r4 el tiempo que deseamos que transcurra
	
		add r4, r3			@como el contador tendrá un valor, almacenamos en r4 dicho valor más el tiempo que queremos que transcurra

ret3:	ldr r3, [r2, #STCLO]	@actualizamos el contador con el tiempo que va transcurriendo
		cmp r3, r4			@comparamos el tiempo actual, r3, con el tiempo al que queremos llegar r4
		bne ret3				@si el tiempo no es igual, saltamos de nuevo a la función ret3 hasta que haya pasado el tiempo deseado
		bx lr	

infi: b infi