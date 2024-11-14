.include "configuration.inc" 
.include "symbolic.inc"

/* Vector Table inicialization */
	mov r0,#0
	ADDEXC 0x1C, fast_interrupt      @only if used


/* Stack init for IRQ mode */	
	mov     r0, #0b11010010   
	msr     cpsr_c, r0
	mov     sp, #0x8000
/* Stack init for FIQ mode */	
	mov     r0, #0b11010001
	msr     cpsr_c, r0
	mov     sp, #0x4000
/* Stack init for SVC mode	*/
	mov     r0, #0b11010011
	msr     cpsr_c, r0
	mov     sp, #0x8000000
	
/* Continue my program here */

	ldr r0, =INTBASE
	ldr r1, =0x083
	str r1, [r0, #INTFIQCON]
	
	mov r1, #0b10010011
	msr cpsr_c, r1
	
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =500000
	add r1, r1, r2
	str r1, [r0, #STC3]
	
	ldr r7, =0

	ldr r0, =GPBASE
	ldr r1, =0x08420E00
	ldr r2, =0x0E00
loop:	
	ldr r8,[r0,#GPLEV0]
	tst r8, #0b01000
	streq r1,[r0,#GPCLR0]
	tst r8, #0b0100
	streq r1,[r0,#GPCLR0]
	streq r2,[r0,#GPSET0]
	ldreq r0, =INTBASE
	ldreq r1, =0x081
	streq r1, [r0, #INTFIQCON]
	beq end
	b loop
	
end:	b end

/* Fast interrupt (only if used) */
fast_interrupt: 
	push {r0, r1, r2}
	
	add r7, #1
	ldr r0,=GPBASE
	ldr r1, =0x08420E00
	
	cmp r7, #1
	streq r1,[r0,#GPSET0]
	cmp r7, #5
	streq r1,[r0,#GPCLR0]
	ldreq r7,=0

	ldr r0, =STBASE
	mov r1, #0b01000
	str r1,[r0,#STCS]
	
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =500000
	add r1, r1, r2
	str r1, [r0, #STC3]

	pop {r0, r1, r2}
	subs  pc, lr, #4
