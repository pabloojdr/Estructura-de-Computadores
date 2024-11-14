/* En el arranque, el código de Ejer2.s dejará encendidos los dos LEDs rojos. A
continuación, quedará sondeando la pulsación de cualquiera de los dos botones. En
función de cuál de los botones ha sido pulsado se quedará encendido sólo el LED rojo
del mismo lado, apagándose el otro. */	

	.set GPBASE, 0x3F200000
	.set GPSEL0, 0x00
	.set GPSEL1, 0x04
	.set GPLEV0, 0x34
	.set GPSET0, 0x1c
	.set GPCLR0, 0x28

.text
	ldr r0, =GPBASE
		 /*xx999888777666555444333222111000*/
	mov r1, #0b00001000000000000000000000000000
	str r1, [r0, #GPSEL0]	@configura GPIO9 como salida (para poder encender el led rojo)
	       /*xx10987654321098765432109876543210*/
	mov r1, #0b00000000000000000000001000000000
	str r1, [r0, #GPSET0]	@enciende el led rojo más a la izquierda
		 /*xx999888777666555444333222111000*/
	mov r2, #0b00000000000000000000000000000001
	str r2, [r0, #GPSEL1]	@configura GPIO10 como salida (para poder encender el led rojo más a la derecha)
	       /*xx10987654321098765432109876543210*/
	mov r2, #0b00000000000000000000010000000000
	str r2, [r0, #GPSET0]	@enciende el led rojo más a la derecha
	
	
	
	       /*xx10987654321098765432109876543210*/
	mov r3, #0b00000000000000000000000000000100	@mueve la posición del primer botón al registro r3
	mov r5, #0b00000000000000000000000000001000 	@mueve la posición del segundo botón al registro r5
bucle:
	ldr r4, [r0,#GPLEV0]  @GPLEV tiene guardados los valores a los que se encuentran los botones (pulsado o no pulsado)
	tst r4, r3	/*carga los bits de los pulsadores y comparamos con los bits 2 y 3 (pulsador 1 y 2 respectivamente)*/
	beq boton1
	
	tst r4, r5
	beq boton2
	
	b bucle
	
boton1:	
	str r1, [r0, #GPCLR0]	@apaga el led rojo más a la izquierda
	mov r2, #0b00000000000000000000000000000001
	str r2, [r0, #GPSEL1]	@configura el led rojo más a la derecha como salida
	       /*xx10987654321098765432109876543210*/
	mov r2, #0b00000000000000000000010000000000
	str r2, [r0, #GPSET0]	@enciende el led rojo más a la derecha
	
	b bucle

boton2: 
	str r2, [r0, #GPCLR0]	@apaga el led rojo más a la derecha
		 /*xx999888777666555444333222111000*/
	mov r1, #0b00001000000000000000000000000000	
	str r1, [r0, #GPSEL0]	@configura el led rojo más a la izquierda como salida
	       /*xx10987654321098765432109876543210*/
	mov r1, #0b00000000000000000000001000000000
	str r1, [r0, #GPSET0]	@enciende el led rojo más a la izquierda
	b bucle
infi: b infi