@;----------------------------------------------------------------
@;   Q15.c: rutines aritmètiques en format Coma Fixa 1:16:15. 
@;----------------------------------------------------------------
@;	santiago.romani@urv.cat
@;	pere.millan@urv.cat
@;	(Març 2021, Març 2022, Març 2023)
@;----------------------------------------------------------------
@;	Programador/a 1: raul.martinm@estudiants.urv.cat
@;	Programador/a 2: jan.torres@estudiants.urv.cat
@;----------------------------------------------------------------
@; add_Q15():	calcula i retorna la suma dels 2 primers operands,
@;  (num1 + num2)	codificats en Coma fixa 1:16:15.
@;				El 3r paràmetre (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;				1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@; R0 = num1 (i resultat)	R1 = num2	R2 = overflow


.bss
		.align 2
	q: .space 4
	r: .space 4
	
.text
		.align 2
		.arm
		
		.global add_Q15
add_Q15:
	push {r1-r4, lr}
	
	mov r4, #0		@; S'estableix que no hi ha overflow en el princpi
	adds r3, r0, r1	@; Es sumen els dos números i s'actualitzen els flags (el flag de overflow s'actualitza aquí)
	bvs .LifOv1
	b .LelseOv1
	
	.LifOv1:
		mov r4, #1	@; S'estableix que sí hi ha overflow a variable local
	.LelseOv1:
	
	strb r4, [r2]	@; S'estableix si hi ha overflow a la variable passada per referència
	mov r0, r3		@; Es retorna la suma
	pop {r1-r4, pc}
	
@; sub_Q15():	calcula i retorna la resta dels 2 primers operands,
@;  (num1 - num2) codificats en Coma fixa 1:16:15.
@;				El 3r paràmetre (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;				1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@; R0 = num1 (i resultat)	R1 = num2	R2 = overflow
		.global sub_Q15
sub_Q15:
	push {r1-r4, lr}
	
	mov r4, #0		@; S'estableix que no hi ha overflow en el princpi
	subs r3, r0, r1	@; Es resten els dos números i s'actualitzen els flags (el flag de overflow s'actualitza aquí)
	bvs .LifOv2
	b .LelseOv2
	
	.LifOv2:
		mov r4, #1	@; S'estableix que sí hi ha overflow a variable local
	.LelseOv2:
	
	strb r4, [r2]	@; S'estableix si hi ha overflow a la variable passada per referència
	mov r0, r3		@; Es retorna la resta
	pop {r1- r4, pc}
	
	
@; mul_Q15():	calcula i retorna el producte dels 2 primers operands,
@;  (num1 * num2)	codificats en Coma fixa 1:16:15.
@;				El 3r paràmetre (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;				1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@; R0 = num1 (i resultat)	R1 = num2	R2 = overflow
		.global mul_Q15
mul_Q15:
	push {r1-r7, lr}
	
	mov r5, #0
	
	smull r3, r4, r0, r1
	mov r3, r3, lsr #15			@; Es prepara el resultat de la multiplicació que s'ha de retornar
	orr r3, r4, lsl #17		
	mov r4, r4, asr #15			@; Es desplacen tants bits com part fraccionària 
								@; hi ha cap a l'esquerra per a poder veure el bit de signe
	
	ldr r6, =0x80000000			@; S'estableix la màscara
	and r7, r4, r6				@; R7 = R4 && MASK_SIGN
	
	.Lif3:
		cmp r3, #0				@; Es mira si el resultat de la multiplicació és negatiu
		bge .Lelse3
		.Lif4:
			cmp r7, r6			@; Es compara el registre amb bit de signe(passat per la màscara), amb la màscara
			beq .Lendif3
			mov r5, #1			@; Si R7 != R6, llavors hi ha hagut overflow
		.Lendif4:
	.Lelse3:
		cmp r4, #0				@; Si el registre amb el bit de signe(passat per la màscara) 
		beq .Lendif3			@; és diferent de 0, significarà que hi ha hagut overflow
		mov r5, #1
	.Lendif3:
	
	mov r0, r3					@; Es retorna el resultat del producte
	strb r5, [r2]				@; S'estableix la variable passada per referència overflow
	pop {r1-r7, pc}


@; div_Q15():	calcula i retorna la divisió dels 2 primers operands,
@;  (num1 / num2) codificats en Coma fixa 1:16:15.
@;				El 3r paràmetre (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;				1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@; R0 = num1 (i resultat)	R1 = num2	R2 = overflow
	.global div_Q15
div_Q15:
	push {r1-r12, lr}
	
	mov r12, r1			@; guardem num2 en r12
	
	.Lif5:
		cmp r1, #0
		bne .Lelse5
		mov r0, #0				@; Resultat = 0
		mov r5, #1				@; Overflow = 1
		b .Lendif5
		
	.Lelse5:
		cmp r1, #0
		bgt .Lcontinue1
		ldr r7, =-32768				@; -32768 = -1 * 2^15
		smull r5, r6, r1, r7		@; Es passa el segon operand a valor absolut
		mov r5, r5, lsr #15
		orr r5, r6, lsl #17
		mov r1, r5
		
		.Lcontinue1:
			mov r11, r2				@; guardem ov en r11
			
			mov r8, r0				@; guardem num1 en r8
			
			ldr r2, =q				@; r2 és el quocient
			
			mov r0, #32768			@; 32768 = 1 * 2^15
			mov r0, r0, lsl #15
			bl div_mod
			ldr r1, [r2]			@; S'obté el valor de la inversa
			
			mov r0, r8				@; Es recupera R0 original (numerador de la divisió)
			mov r2, r11          	@; es recupera l'overflow
			
			bl mul_Q15
			ldrb r5,[r2]			@; es guarda r5 en r2
			
			cmp r12, #0				@; Si num2 era negatiu, se li canvia el signe al resultat de la divisió
			bgt .Lendif5
			smull r9, r10, r0, r7  	@; cambiar singo a r0
			mov r9, r9, lsr #15
			orr r9, r10, lsl #17
			mov r0, r9
			
	.Lendif5:

strb r5, [r2]						@; r2=ov
pop {r1-r12, pc}

.end
