/*-- $Id: data.c,v 1.7 2000/04/10 14:09:29 maechler Exp maechler $
 *
 * Global data[] -- reading and context --
 *
 * Called from  vlmc.c, likestat.c & predict.c
 */
#include <stdio.h>
#include <string.h>

#include "alphabet.h"

/* --- GLOBAL --- */
extern int
#ifdef Standalone
# define MAXLEN 200000
  data[MAXLEN];
#else
  *data;
#endif

int context(int i, int level)/* FIXME --- use *data arg --- performance loss?*/
{
  return (i >= level) ? data[i - level] : -1;
}

#ifdef Standalone

void read_data(int *data, int *data_len)
{
  /* Read from STDIN into global data[], saving data_len */
  int c;
  int i;

  while (((c = getchar()) != EOF) && (*data_len < MAXLEN))
    for (i = 0; i < alpha_len; i++)
      if (c == alpha[i]) {
        data[(*data_len)++] = i;
        break;
      }
}
#endif
