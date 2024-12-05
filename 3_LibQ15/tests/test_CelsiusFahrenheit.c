/*----------------------------------------------------------------
|   Testing temperature-scale conversion routines;
| ----------------------------------------------------------------
|	santiago.romani@urv.cat
|	pere.millan@urv.cat
|	(Abril 2021, Mar� 2022, Mar� 2022)
| ----------------------------------------------------------------*/

#include "Q15.h"				/* external declarations of types, defines and
								   macro for dealing with Q15 numbers */
#include "CelsiusFahrenheit.h"	/* external declarations of function
								   prototypes for temperature conversions */


/* type definition of the structured record that holds the test case values */
typedef struct {
	char scale;			/* letter of input scale ('C' or 'F') */
	Q15 input;			/* input temperature value for conversion */
	Q15 xresult;		/* Expected result of the operation */
} test_ops_struct;

/* the list of test case values */
test_ops_struct test_case[] =
	/* Tests Celsius -> Fahrenheit */
{{'C', MAKE_Q15(-273.15), 				/*  0: absolute min. �C temperature */
	   MAKE_Q15(-459.67)},
 {'C', MAKE_Q15(-40.0), 				/*  1: equal �C and �F */
	   MAKE_Q15(-40.0)},
 {'C', MAKE_Q15(-17.7777777777778), 	/*  2: conversion to 0 �F */
	   MAKE_Q15(0.0)},
 {'C', MAKE_Q15(-17.777), 				/*  3: nearby conversion to 0 �F */
	   MAKE_Q15(0.0014)},
 {'C', MAKE_Q15(-17.6), 				/*  4: another nearby conversion to 0 �F */
	   MAKE_Q15(0.32)},
 {'C', MAKE_Q15(-1.125), 				/*  5: small negative �C (positive �F) */
	   MAKE_Q15(29.975)},
 {'C', MAKE_Q15(0.0),					/*  6: 0.0 �C = 32.0 �F */
	   MAKE_Q15(32.0)},
 {'C', MAKE_Q15(0.000244140625), 		/*  7: minimal fraction in �C */
	   MAKE_Q15(32.000439453125)},			// result = 32 + converted fract.
 {'C', MAKE_Q15(1.0), 					/*  8: unit �C */
	   MAKE_Q15(33.8)},
 {'C', MAKE_Q15(31.1), 					/*  9: common positive �C */
	   MAKE_Q15(87.98)},
 {'C', MAKE_Q15(4500.0), 				/* 10: large positive �C */
	   MAKE_Q15(8132.0)},
 {'C', MAKE_Q15(36391.1111), 			/* 11: max. convertable �C */
	   MAKE_Q15(65535.9999)},

	/* Tests  Fahrenheit -> Celsius */
 {'F', MAKE_Q15(-459.67), 				/* 12: absolute min. �F temperature */
	   MAKE_Q15(-273.15)},
 {'F', MAKE_Q15(-40.0), 				/* 13: equal �F and �C */
	   MAKE_Q15(-40.0)},
 {'F', MAKE_Q15(-0.000122070312), 		/* 14: minimal neg. fraction in �F */
	   MAKE_Q15(-17.7778455946178)},		// result = -17 - converted fract.
 {'F', MAKE_Q15(0.0),					/* 15: 0.0 �F = -17.777... �C */
	   MAKE_Q15(-17.7777777777778)},
 {'F', MAKE_Q15(1.0),					/* 16: unit �F */
	   MAKE_Q15(-17.2222222222222)},
 {'F', MAKE_Q15(31.999), 				/* 17: small converted �C */
	   MAKE_Q15(-0.0006)},
 {'F', MAKE_Q15(31.9997802734384), 		/* 18: small converted �C */
	   MAKE_Q15(-0.000122070311999857)},
 {'F', MAKE_Q15(32.0), 					/* 19: 0.0 �C */
	   MAKE_Q15(0.0)},
 {'F', MAKE_Q15(32.009), 				/* 20: small �C */
	   MAKE_Q15(0.00500000000000019)},
 {'F', MAKE_Q15(59.0), 					/* 21: common positive �F */
	   MAKE_Q15(15.0)},
 {'F', MAKE_Q15(451.0), 				/* 22: temperature for burning books*/
	   MAKE_Q15(232.777777777778)},
 {'F', MAKE_Q15(65535.9999), 			/* 23: max. convertable �F */
	   MAKE_Q15(36391.1111)}
};


unsigned int abs_value(int x) { return(x < 0 ? -x : x); }
unsigned int error_margin(char scale, int expected_result);


int main(void)
{
	unsigned int i;						/* loop index */
	Q15 result;							/* routine results */
	unsigned int num_ok = 0;			/* number of right tests */
	unsigned int num_ko = 0;			/* number of wrong tests */
	unsigned int num_tests = 			/* total number of tests */
					sizeof(test_case) / sizeof(test_ops_struct);
	unsigned int abs_error, error_limit;

	/********* evaluate the list of test case values *********/
	for (i = 0; i < num_tests; i++)
	{
		if (test_case[i].scale == 'C')
			result = Celsius2Fahrenheit(test_case[i].input);
		else
			result = Fahrenheit2Celsius(test_case[i].input);
		
		abs_error = abs_value(result - test_case[i].xresult);
		error_limit = error_margin(test_case[i].scale, test_case[i].xresult);
			/* check if abs_error is under a sensible margin */
		if (abs_error <= error_limit)
			num_ok++;
		else
			num_ko++;
	}

/* TESTING POINT: check if number of ok tests 
				  is equal to number of total tests
				  or if number of ko tests is 0.
	(gdb) p num_ok
	(gdb) p num_ko
	(gdb) p num_tests
*/

/* BREAKPOINT */
	return(0);
}


/* Compute a sensible margin for absolute error of Celsius to Fahrenheit or
	Fahrenheit to Celsius transformations based on rational numbers expressed
	in Q15 format.
	Parameters:
		scale 	-> 'C' or 'F': 	'C' means Celsius to Fahrenheit and
								'F' means Fahrenheit to Celsius
		expected_result (Q15):	the expected transformed value
	Result:
		error limit, in absolute Q15 units.
*/
unsigned int error_margin(char scale, int expected_result)
{
	unsigned int result = 0;

	if (scale == 'C')
	{
			/* subtract 200.000 units to expected result, to align the zero
				crossing point of result function around 0 �C;
			   convert negative into positive aligned results
			   shift 15 bits to the left, so as to divide corrected result by
				32.768, which is equivalent to 0.003% of expected result
				(0.003% is the relative error of representing 9/5 in Q15)
			   add 3 to give an extra amount of margin for unexpectedly high
				variations in absolute error.
			*/
		result = (abs_value(expected_result-200000) >> 15) + 3;	
	}
	else // if (scale == 'F')
	{
			/* convert negative into positive results
			   shift 12 bits to the left, so as to divide corrected result by
				4.096, which is equivalent to 0.02% of expected result
				(0.02% is the relative error of representing 5/9 in Q15)
			   add 1 to give an extra amount of margin for unexpectedly high
				variations in absolute error.
			*/
		result = (abs_value(expected_result) >> 12) + 1;
	}
	return result;
}

