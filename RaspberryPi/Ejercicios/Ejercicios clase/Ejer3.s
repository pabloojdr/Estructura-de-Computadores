/*Ahora, modifica el programa Ejer1.s para crear el nuevo Ejer3.s en el que se alterne el
encendido y apagado del led rojo conectado al GPIO 9. ¿Qué observas?¿Funciona
como esperabas? */

	.set GPBASE, 0x3F200000
	.set GPSEL0, 0x00
	.set GPSET0, 0x1c
	.set GPCLR0, 0x28

.text
	ldr r0, =GPBASE
		 /*xx999888777666555444333222111000*/
	mov r1, #0b00001000000000000000000000000000
	str r1, [r0, #GPSEL0]	@configura el led rojo como salida

	       /*xx10987654321098765432109876543210*/
	mov r1, #0b00000000000000000000001000000000

bucle:
	str r1, [r0, #GPSET0]	@enciende el led rojo
	str r1, [r0, #GPCLR0]	@apaga el led rojo	
	b bucle
	
@Este programa no funciona como se esperaba, pues no existe un tiempo de espera entre el encendido y el apagado del led