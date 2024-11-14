/* Escribe un programa que encienda el primer led rojo de la placa de expansión (señal
GPIO 9). Sabemos que, en el arranque van a estar todos apagados. Llámale Ejer1.s.
Recuerda que ante la inexistencia de un SO al que retornar, tus programas deben
terminar en un bucle infinito.*/

	.set GPBASE, 0x3F200000
	.set GPSEL0, 0x00
	.set GPSET0, 0x1c

.text
	ldr r0, =GPBASE
	         /*xx999888777666555444333222111000 */
	mov r1, #0b00001000000000000000000000000000   @configura GPIO9 como salida
	str r1, [r0, #GPSEL0]
		    
		 /*10987654321098765432109876543210*/
	mov r1, #0b00000000000000000000001000000000   @enciende la luz roja (asignada al número 9)
	str r1, [r0, #GPSET0]
infi: 
	b infi
	