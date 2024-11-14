/* Leyendo el contador CLO del timer para controlar el tiempo transcurrido, alterna el
encendido y apagado del led rojo conectado a la señal GPIO 9 de manera que se haga
visible al ojo humano (mantenlo 1 seg., en cada estado). */



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
	mov r5, #0b00001000000000000000000000000000
	str r5, [r4, #GPFSEL0]		@configura el led rojo como salida

/* guia bits	   01987654321098765432109876543210 */	
	mov r5, #0b00000000000000000000001000000000

ldr r0, =STBASE
ldr r1, =1000000 @ 1s = 1000000 micros

bucle: 
		bl espera				@espera el tiempo determinado dentro de esta función
		str r5, [r4, #GPSET0] 	@enciende el led rojo
		bl espera				@espera el tiempo determinado dentro de esta función
		str r5, [r4, #GPCLR0] 	@apaga el led rojo
		b bucle

espera: 
		push {r4,r5} 			
		ldr r4, [r0, #STCLO]	@establece el contador en r4
		add r4, r1			@como el contador tendrá un valor, almacenamos en r4 dicho valor más el tiempo de espera que queremos poner para las luces
ret1:	
		ldr r5, [r0, #STCLO]	@actualizamos el contador con el tiempo que va transcurriendo
		cmp r5, r4			@comparamos el tiempo actual, r3, con el tiempo al que queremos llegar r4
		blo ret1				@si el tiempo no es igual, saltamos de nuevo a la función ret1 hasta que haya pasado el tiempo deseado
		pop {r4,r5}			
		bx lr				@una vez pasado el tiempo volvemos a la siguiente linea desde donde ha saltado al bucle espera

infi: b infi