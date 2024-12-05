@;/*----------------------------------------------------------------
@;  "avgmaxmintemp.c": rutines de càlcul de valors mitjans, màxims
@;	i mínims d'una taula de temperatures, expressades en graus
@;	Celsius o Fahrenheit, en format Q15 (coma fixa 1:16:15).
@;----------------------------------------------------------------
@;	santiago.romani@urv.cat
@;	pere.millan@urv.cat
@;	(Març 2021, Març 2022, Març 2023)
@;----------------------------------------------------------------
@;	Programador/a 1: raul.martinm@estudiants.urv.cat
@;	Programador/a 2: jan.torres@estudiants.urv.cat
@;----------------------------------------------------------------*/

.include "avgmaxmintemp.i"

.bss
		.align 2
	q: .space 4
	r: .space 4
.text
		.align 2
		.arm

@; ;avgmaxmin_city(): calcula la temperatura mitjana, màxima i mínima d'una
@;				ciutat d'una taula de temperatures, amb una fila per ciutat i
@;				una columna per mes, expressades en graus Celsius en format
@;				Q15.
@;	Paràmetres:
@;		R0	=	ttemp[][12]	->	taula de temperatures, amb 12 columnes i nrows files
@;		R1	=	nrows		->	número de files de la taula
@;		R2	=	id_city		->	índex de la fila (ciutat) a processar
@;		R3	=	*mmres		->	adreça de l'estructura t_maxmin que retornarà els
@;							resultats de temperatures màximes i mínimes
@; 		R0	=	temperatura mitjana, expressada en graus Celsius, en format Q15.

	.global avgmaxmin_city
avgmaxmin_city:
		push {r4-r12, lr}
		mov r7, #4				@; 4 bytes (tamany de cada element, de cada columna)
		mov r5, #12
		mul r4, r2, r5			@; 12 pels mesos (columnes) i 4 pels bytes que ocupa cada element
		mul r4, r7
		add r0, r4				@; Es sumen a la posició 0 els elements que hi ha abans de la ciutat 
								@; determinada (ttemp(id_city,month) = (0,0) + (fila ciutat*NC)*Tamany)
		mov r5, #1				@; r5 = i = 1
		ldr r8, [r0]			@; avg = temperatura del primer mes (ttemp[id_city][0])
		mov r9, r8				@; min = temperatura del primer mes
		mov r10, r8				@; max = temperatura del primer mes
		mov r11, #0				@; idmin = 0
		mov r12, #0				@; idmax = 0
		
		.Lfor:
			cmp r5, #12
			bhs .Lendfor		@; Si i > 12 (mesos de l'any) surt del bucle
			ldr r6, [r0, r7]	@; Llegeix els primers 4 bytes a r6
			add r8, r6
		
		.Lif1:
			cmp r6, r10			@; Si tvar <= max surt de l'if 
			ble .Lendif1		
			mov r10, r6			@; max = tvar
			mov r12, r5			@; idmax = i
		.Lendif1:
		
		.Lif2:
			cmp r6, r9			@; Si tvar >= min surt de l'if 
			bhs .Lendif2		
			mov r9, r6			@; min = tvar
			mov r11, r5			@; idmin = i
		.Lendif2:
		
			add r5, #1			@; i++
			add r7, #4			@; següent columna
			b .Lfor
			
		.Lendfor:
	
		mov r0, r8
		cmp r0, #0
		bge .Lcontinue2
		mov r5, #-1
		smull r6, r7, r0, r5 			@; avg=-avg
		mov r6, r6, lsr #15
		orr r6, r7, lsl #17
		
		mov r0, r6
		
		.Lcontinue2:
	
		mov r1, #12
		ldr r2, =q
		bl div_mod
		ldr r6, =q
		
		cmp r8, #0
		bge .Lcontinue3
		smull r8, r7, r6, r5 			@; avg=-avg
		mov r8, r8, lsr #15
		orr r8, r7, lsl #17
		
		mov r0, r8
		.Lcontinue3:
		
		str r9, [r3]			@; Es guarda en la primera posició de r3 la temp mínima en Celsius
		str r10, [r3, #4]		@; Es guarda en la segona posició de r3 la temp màxima en Celsius
		mov r0, r9				@; Es posa a r0 la temp min perquè és el registre que la rutina fa servir
		bl Celsius2Fahrenheit
		str r0, [r3, #8]		@; Es guarda en la tercera posició de r3 la temp mínima en Fahrenheit
		
		mov r0, r10
		bl Celsius2Fahrenheit
		str r0, [r3, #12]		@; Es guarda en la quarta posició de r3 la temp màx en Fahrenheit
		
		strh r11, [r3, #16]		@; Es guarda en la cinquena posició de r3 la posició de la temp mín
		strh r12, [r3, #18]		@; Es guarda en la sisena posició de r3 la posició de la temp màx
		
		ldr r0, [r6]				@; Es guarda avg a R0 -> return(avg)
		pop {r4-r12, pc}
		
		
@;avgmaxmin_month(): calcula la temperatura mitjana, màxima i mínima d'un mes
@;				d'una taula de temperatures, amb una fila per ciutat i una
@;				columna per mes, expressades en graus Celsius en format Q15.
@;	Paràmetres:
@;		R0	=	ttemp[][12]	->	taula de temperatures, amb 12 columnes i nrows files
@;		R1	=	nrows		->	número de files de la taula (mínim 1 fila)
@;		R2	=	id_month	->	índex de la columna (mes) a processar
@;		R3	=	*mmres		->	adreça de l'estructura t_maxmin que retornarà els
@;						resultats de temperatures màximes i mínimes
@;		R0	=  	temperatura mitjana, expressada en graus Celsius, en format Q15.
	
	.global avgmaxmin_month	
avgmaxmin_month:
		push {r4-r12, lr}
		mov r4, #0		@; idmin = 0
		mov r5, #0		@; idmax = 0
		mov r6, #4		@; Tamany de cada element
		mul r10, r6, r2	@; R10 = 4 * id_month (elements abans de l'escollit)
		add r0, r10
		ldr r7, [r0]	@; R7 = avg
		mov r8, r7		@; R8 = màx
		mov r9, r7		@; R9 = mín
		
		mov r10, #1		@; R10 = i = 1
		mov r11, #48	@; R11 = 12 * 4 (Elements fins la pròxima temperatura del mes multiplicat pel tamany)
		
		ldr r12, [r0, r11]	@; Temperatura actual
		add r7, r12
		

		.Lwhile:
			cmp r10, r1
			bhs .Lendwhile
			
			.Lif3:
				cmp r12, r8
				ble .Lendif3
				mov r8, r12
				mov r5, r10		@; R5(idmax) = R10
			.Lendif3:
			
			.Lif4:
				cmp r12, r9
				bhs .Lendif4
				mov r9, r12
				mov r4, r10
			.Lendif4:
			
			add r11, #48		@; Es sumen els elements per arribar a la pròxima temp a la següent fila
			add r10, #1			@; i++
			ldr r12, [r0, r11]	@; Temperatura actual
			add r7, r12
			b .Lwhile
		.Lendwhile:
		
		.Lif5:
			cmp r7, #0				@; Es comprova si abg és negatiu o positiu
			bge .Lelse5
			mov r11, #-1
			smull r6, r10, r7, r11	@; Es canvia de signe i s'assignen els bits de més bits a R6
			mov r6, r6, lsr #15
			orr r6, r10, lsl #17
			mov r0, r6
			b .Lendif5
			
		.Lelse5:
			mov r0, r7				@; R0 = avg sense dividir entre nrows
		.Lendif5:
		ldr r2, =q
		bl div_mod				@; Es guarda el quocient (avg) a R2
		ldr r10, =q
		
		str r9, [r3]			@; Es guarda en la primera posició de r3 la temp mínima en Celsius
		str r8, [r3, #4]		@; Es guarda en la segona posició de r3 la temp màxima en Celsius
		mov r0, r9				@; Es posa a r0 la temp min perquè és el registre que la rutina fa servir
		bl Celsius2Fahrenheit
		str r0, [r3, #8]		@; Es guarda en la tercera posició de r3 la temp mínima en Fahrenheit
		
		mov r0, r8
		bl Celsius2Fahrenheit
		str r0, [r3, #12]		@; Es guarda en la quarta posició de r3 la temp màx en Fahrenheit
		
		strh r4, [r3, #16]		@; Es guarda en la cinquena posició de r3 la posició de la temp mín
		strh r5, [r3, #18]		@; Es guarda en la sisena posició de r3 la posició de la temp màx
		
		ldr r0, [r10]				@; Es guarda avg a R0 -> return(avg)
		pop {r4-r12, pc}



