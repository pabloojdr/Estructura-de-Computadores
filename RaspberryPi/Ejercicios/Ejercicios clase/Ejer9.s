/*Prepara un código, que llamarás Ejer9.s, que haga parpadear el LED asociado al GPIO9
usando interrupciones. Para ello, la RTI deberá reprogramar la IRQ del comparador del
timer para que vuelva a producirse, además de encender o apagar el led en función de
lo que hizo en su última invocación. Tanto el encendido como el apagado durarán
medio segundo.*/

.include "inter.inc"

.text
	mov r0, #0				@iniciamos el vector interruptor
	ADDEXC 0x18, irq_handler
		
	mov r0, #0b11010010			@iniciamos el modo IRQ
	msr cpsr_c, r0
	mov sp, #0x8000
	
	mov r0, #0b11010011			@iniciamos el modo SVC
	msr cpsr_c, r0
	mov sp, #0x8000000
	
	ldr r0, =GPBASE			@configuramos GPIO9 como salida
		  @xx999888777666555444333222111000
	mov r1, #0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0]
	
	ldr r0, =STBASE			@programamos el contador C1 para una futura interrupción (guardamos el contador en C1(?)
	ldr r1, [r0, #STCLO]
	ldr r2, =500000			@añadimos medio segundo
	add r1, r2
	str r1, [r0, #STC1]
	
	ldr r0, =INTBASE			@habilitamos la interrupción por el comparador C1
	mov r1, #0b0010
	str r1, [r0, #INTENIRQ1]
		
	mov r0, #0b01010011			@inciamos el modo supervisor
	msr cpsr_c, r1
	
	ldr r3, =0				@inicializamos r3 para poder usarlo posteriormente en el handler
	
bucle: 	b bucle				@siempre el main tiene que acabar con un bucle infinito

irq_handler:				
		push {r0,r1,r2}
		
		ldr r0, =GPBASE
	          @01987654321098765432109876543210
		mov r1, #0b00000000000000000000001000000000
	
		eors r3, #1 			@activa la flag Z y en función de eso decidimos si se enciende o se apaga el led
		streq r1, [r0, #GPSET0]	@enciendo el led
		strne r1, [r0, #GPCLR0]	@apago el led
	
		ldr r0, =STBASE
		mov r1, #0b0010
		str r1, [r0, #STCS]
	
		ldr r0, =STBASE		@programamos el contador C1 para una futura interrupción (guardamos el contador en C1(?)
		ldr r1, [r0, #STCLO]
		ldr r2, =500000		@añadimos medio segundo
		add r1, r2
		str r1, [r0, #STC1]
	
		pop {r0,r1,r2}
		subs pc, lr, #4