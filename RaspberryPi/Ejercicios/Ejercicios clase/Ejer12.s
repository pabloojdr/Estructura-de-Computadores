/*El código de Ejer12.s en el arranque dejará encendidos los dos LEDs rojos. La pulsación
de cualquiera de los dos botones provocará una IRQ, cuyo servicio consistirá en
determinar cuál de los botones ha sido pulsado y encender sólo el LED rojo del mismo
lado, apagándose el otro. Se trata de conseguir la misma funcionalidad que con
Ejer2.s, pero utilizando en este caso interrupciones en vez de polling/sondeo.*/

.include "inter.inc"

.text
	ADDEXC 0x18, irq_handler
	
	mov r0, #0b11010010
	msr cpsr_c, r0
	mov sp, #0x8000
	
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000
	
	ldr r0,  =GPBASE
		  @xx999888777666555444333222111000
	mov r1, #0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0]
	
	mov r1, #0b00000000000000000000000000000001
	str r1, [r0, #GPFSEL1]
	
		  @1987654321098765432109876543210
	mov r1, #0b0000000000000000000011000000000
	str r1, [r0, #GPSET0]
	
	mov r1, #0b0000000000000000000000000001100
	str r1, [r0, #GPFEN0]
	ldr r0, =INTBASE
	
		  @1987654321098765432109876543210
	mov r1, #0b0000000000100000000000000000000
	str r1,[r0, #INTENIRQ2]
	mov r0, #0b01010011
	msr cpsr_c, r0
	
bucle: b bucle

irq_handler:
	push {r0, r1}
	
	ldr r0, =GPBASE
		 	@1987654321098765432109876543210
	mov r1, #0b0000000000000000000011000000000
	str r1, [r0, #GPCLR0]
	
	ldr r1, [r0, #GPEDS0]
	ands r1, #0b000000000000000000000000000100
	
		    	  @1987654321098765432109876543210
	movne r1, #0b0000000000000000000001000000000
	moveq r1, #0b0000000000000000000010000000000
	str r1, [r0, #GPSET0]
	
	mov r1, #0b000000000000000000000000000001100
	str r1, [r0, #GPEDS0]
	pop {r0, r1}
	subs pc, lr, #4
	