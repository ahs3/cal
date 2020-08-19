#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	char *dowstr[] = { "sun", "mon", "tue", "wed", "thu", "fri", "sat" };

	int month = atoi(argv[1]);
	int day = atoi(argv[2]);
	int year = atoi(argv[3]);
	int dow;

	int k, m, d, c;

	/* Zeller's Rule */
	k = day;				/* k = day of month */
	printf ("k = %d\n", k);
	m = month < 3 ? month + 10 : month - 2;	/* m = month, Mar = 1 */
	printf ("m = %d\n", m);
	d = year % 100;				/* D = last 2 digits of year */
	printf ("d0 = %d\n", d);
	d = month < 3 ? d - 1 : d;
	printf ("d1 = %d\n", d);
	c = year / 100;				/* c = century */
	printf ("c = %d\n", c);

	dow = k + ((13*m-1) / 5) + d + (d / 4) + (c / 4) - (2 * c);
	dow = dow < 0 ? (dow % (-7)) + 7 : dow % 7;

	printf ("%4d-%02d-%02d : %s (%d)\n", year, month, day, dowstr[dow], dow);
}
