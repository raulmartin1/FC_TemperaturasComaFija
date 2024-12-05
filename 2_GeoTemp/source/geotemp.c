/*-----------------------------------------------------------------------
|   "geotemp.c":
|		programa per calcular els valors mig, m�xim i m�nim d'una taula
|	de temperatures, expressades en graus �C o �F i en format Q15, on
|	cada fila correspon a una ciutat i cada columna a un mes.
|	Les taules amb la informaci� estan definides en un altre m�dul
|	(variables globals externes).
|------------------------------------------------------------------------
|	santiago.romani@urv.cat
|	pere.millan@urv.cat
|	(Abril 2021, Mar� 2022, Mar� 2023)
| -----------------------------------------------------------------------*/

#include "Q15.h"				/* Q15: tipus Coma Fixa 1:16:15 */
#include "divmod.h"				/* rutina div_mod(), en "LibFonCompus.a" */
#include "CelsiusFahrenheit.h"	/* rutines de conversi� C->F i F->C */
#include "avgmaxmintemp.h"		/* mmres: tipus de retorn de m�xim i m�nim */
#include "geotemp.h"			/* t_cityinfo: tipus amb info. de ciutat */
#include "data.h"				/* definici� de dades externes */


/* normalitzar_temperatures(): funci� per a convertir les temperatures
			expressades en graus Fahrenheit a graus Celsius, segons el
			vector d'informaci� de les ciutats registrades.
	Par�metres:
		vinfo[]		-> vector amb una entrada per ciutat, indicant el nom
					   i l'escala utilitzada per expressar les temperatures,
		ttemp[][12]	-> taula amb una fila per ciutat i una columna per mes;
					   se suposa que les temperatures de cada fila estaran
					   expressades en l'escala indicada en t_info[];
		num_cities	-> n�mero de ciutats, tant al vector tinfo[] com a la
					   matriu ttemp[];
	Resultats:
		ttemp[][12]	-> les temperatures convertides a graus Celsius es
					   guardaran sobre la mateixa taula d'entrada (pas per
					   referencia).
*/
void normalitzar_temperatures(t_cityinfo vinfo[], Q15 ttemp[][12], unsigned short num_cities)
{
	unsigned short i, j;
	
	for (i = 0; i < num_cities; i++)	// recorregut de totes les ciutats
		if (vinfo[i].scale == 'F')		// si l'escala utilitzada �s Fahrenheit
			for (j = 0; j < 12; j++)	// recorregut de tots els mesos
				ttemp[i][j] = Fahrenheit2Celsius(ttemp[i][j]);
}



int main(void)
{
	Q15	avgres[4];
	t_maxmin maxminres[4];
	
	normalitzar_temperatures(info_HNord, tempHNord_2020, NUMCITIESHNORD);
	normalitzar_temperatures(info_HSud, tempHSud_2020, NUMCITIESHSUD);
	
			// c�lculs sobre George Town (Cayman Island)
	avgres[0] = avgmaxmin_city(tempHNord_2020, NUMCITIESHNORD, 6, &maxminres[0]);
			// c�lculs sobre el mes d'agost (hemisferi nord)
	avgres[1] = avgmaxmin_month(tempHNord_2020, NUMCITIESHNORD, 7, &maxminres[1]);
			// c�lculs sobre Wellington (New Zealand)
	avgres[2] = avgmaxmin_city(tempHSud_2020, NUMCITIESHSUD, 18, &maxminres[2]);
			// c�lculs sobre el mes de desembre (hemisferi sud)
	avgres[3] = avgmaxmin_month(tempHSud_2020, NUMCITIESHSUD, 11, &maxminres[3]);
	
	
	Q15 dump = avgres[0];		// evitar warning "'avgres' set but not used"
	dump = dump;				// evitar warning "'dump' set but not used"
/* TESTING POINT: check the results
	(gdb) p avgres			-> {913840, 827041, 423253, 626041}
	(gdb) p maxminres[0]	-> {844665, 973914, 2568962, 2801609, 0, 7}
	(gdb) p maxminres[1]	-> {180224, 1258291, 1372977, 3313484, 4, 13}
	(gdb) p info_HNord[4].name	-> "Dikson"
	(gdb) p info_HNord[13].name	-> "Reggane"
	(gdb) p maxminres[2]	-> {291635, 563610, 1573515, 2063067, 6, 1}
	(gdb) p maxminres[3]	-> {265421, 910950, 1526330, 2688274, 15, 12}
	(gdb) p info_HSud[15].name	-> "Stanley"
	(gdb) p info_HSud[12].name	-> "Port Moresby"	
*/

/* BREAKPOINT */
	return(0);
}
