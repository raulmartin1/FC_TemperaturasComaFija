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

.include "Q15.h"

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
		
		ldr r1, =58982			@; r1 = 9/5 * 2^15 = 58.982
		bl mul_Q15				@; r0 = TempC * r1
		
		ldr r1, =1048576		@; r1 = 1.048.576 | 1.048.576 = 32 * 2^15
		
		bl add_Q15	
		
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
		
		ldr r1, =1048576		@; 1.048.576 = 32 * 2^15
		bl sub_Q15
		
		ldr r1, =18204			@; r1 = 5/9 * 2^15 = 18.204	
		bl mul_Q15				@; r0 = r0 * r1 
		
		pop {r1-r3, pc}

