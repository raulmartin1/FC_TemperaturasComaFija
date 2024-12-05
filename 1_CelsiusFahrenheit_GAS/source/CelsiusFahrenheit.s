@;----------------------------------------------------------------
@;  CelsiusFahrenheit.s: rutines de conversió de temperatura en 
@;						 format Q15 (Coma Fixa 1:16:15). 
@;----------------------------------------------------------------
@;	santiago.romani@urv.cat
@;	pere.millan@urv.cat
@;	(Març 2021, Març 2022, Març 2023)
@;----------------------------------------------------------------
@;	Programador/a 1: raul.martinm@estudiants.urv.cat
@;	Programador/a 2: jan.torres@estudiants.urv.cat
@;----------------------------------------------------------------*/

.include "Q15.i"

.text
		.align 2
		.arm

@; Celsius2Fahrenheit(): converteix una temperatura en graus Celsius a la
@;						temperatura equivalent en graus Fahrenheit, utilitzant
@;						valors codificats en Coma Fixa 1:16:15.
@;	Entrada:
@;		input 	-> R0
@;	Sortida:
@;		R0 		-> output = (input * 9/5) + 32.0;
	.global Celsius2Fahrenheit
Celsius2Fahrenheit:
		push {r1-r3, lr}
		mov r1, #0
		ldr r3, =58982			@; 9/5 * 2^15 = 58.982
		smull r1, r2, r0, r3 	@; r1 = r0 * 9/5 (32 bits resultants amb menys pes) | r2 = r0 * 9/5 (32 bits resultants amb més pes)
		
		mov r1, r1, lsr #15		@; Desplaçament de 15 bits de la part baixa a la dreta
		orr r1, r2, lsl #17		@; S'omplen 17 bits de la part alta (preferentment) a l'esquerra
		
		add r0, r1, #1048576	@; r0 = r1 + 1.048.576 | 1.048.576 = 32 * 2^15
		pop {r1-r3, pc}



@; Fahrenheit2Celsius(): converteix una temperatura en graus Fahrenheit a la
@;						temperatura equivalent en graus Celsius, utilitzant
@;						valors codificats en Coma Fixa 1:16:15.
@;	Entrada:
@;		input 	-> R0
@;	Sortida:
@;		R0 		-> output = (input - 32.0) * 5/9;
	.global Fahrenheit2Celsius
Fahrenheit2Celsius:
		push {r1-r3, lr}
		mov r1, #0
		ldr r3, =18204 			@; 5/9 * 2^15 = 18.204				
		
		sub r0, r0, #1048576 	@; r0 = (input - 32) | 1.048.576 = 32 * 2^15
		smull r1, r2, r0, r3	@; r1 = r0 * 5/9 (32 bits resultants amb menys pes) | r2 = r0 * 5/9 (32 bits resultants amb més pes) 
		
		mov r1, r1, lsr #15		@; Desplaçament de 15 bits de la part baixa a la dreta
		orr r1, r2, lsl #17		@; S'omplen 17 bits de la part alta (preferentment) a l'esquerra
		
		mov r0, r1				@; r0 = temperatura en Celsius resultant (r1)
		pop {r1-r3, pc}

