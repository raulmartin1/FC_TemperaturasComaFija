@;-----------------------------------------------------------------------
@;  Description: a program to check the temperature-scale conversion
@;				functions implemented in "CelsiusFahrenheit.c".
@;	IMPORTANT NOTE: there is a much confident testing set implemented in
@;				"tests/test_CelsiusFahrenheit.c"; the aim of "demo.s" is
@;				to show how would it be a usual main() code invoking the
@;				mentioned functions.
@;-----------------------------------------------------------------------
@;	Author: Santiago Romani (DEIM, URV)
@;	Date:   March/2022, March/2023 
@;-----------------------------------------------------------------------
@;	Programmer 1: raul.martinm@estudiants.urv.cat
@;	Programmer 2: jan.torres@estudiants.urv.cat
@;-----------------------------------------------------------------------*/

.data
		.align 2
	temp1C:	.word 0x00119AE1		@; temp1C = 35.21 ºC
	temp2F:	.word 0xFFF42000		@; temp2F = -23.75 ºF

.bss
		.align 2
	temp1F:	.space 4				@; expected conversion:  95.377532958984375 ºF
	temp2C:	.space 4				@; expected conversion: -30.971466064453125 ºC 


.text
		.align 2
		.arm
		.global main
main:
		push {r1-r3, lr}
		ldr r1, =temp1C
		ldr r2, =temp1F
		ldr r0, [r1]
		bl Celsius2Fahrenheit	@; temp1F = Celsius2Fahrenheit(temp1C);
		str r0, [r2]
		
		ldr r1, =temp2F
		ldr r3, =temp2C
		ldr r0, [r1]
		bl Fahrenheit2Celsius	@; temp2C = Fahrenheit2Celsius(temp2F);
		str r0, [r3]

@; TESTING POINT: check the results
@;	(gdb) p /x temp1F		-> 0x002FB053 
@;	(gdb) p /x temp2C		-> 0xFFF083A7 
@; BREAKPOINT
		mov r0, #0					@; return(0)
		
		pop {r1-r3, pc}

.end

