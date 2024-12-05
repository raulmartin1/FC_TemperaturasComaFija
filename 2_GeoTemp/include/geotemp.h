/*---------------------------------------------------------------------
|   Declaraci� de tipus per a informaci� del programa "geotemp.c".
| ---------------------------------------------------------------------
|	santiago.romani@urv.cat
|	pere.millan@urv.cat
|	(Mar� 2021)
| ---------------------------------------------------------------------*/

#ifndef GEOTEMP_H
#define GEOTEMP_H

  	/* declaraci� del tipus t_cityinfo */
typedef struct
{	
	char *name;			// nom de la ciutat
	char scale;			// escala utilitzada ('C': Celsius, 'F': Fahrenheit)
} t_cityinfo;


#endif 	/* GEOTEMP_H */