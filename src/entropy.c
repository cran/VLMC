/* -- $Id: entropy.c,v 1.8 2001/10/03 07:56:02 maechler Exp $ */
#include <math.h>

#include "vlmc.h"
#include "subutil.h"

/* Export the routintes to be called from R / S-plus.
 *
 * entropy() and entropy2() are in ./util.c
 */

void entropy_sub(int* vlmc_vec, int* size_vlmc,
		 int* cardX,
		 /* Result : */
		 double *r)
{
/* The same number --- apart from factor log(cardX) ---
   as main program   "draw -e" used to give */

  node_t *top;
  int next_ind = 0;

  top = load_tree(vlmc_vec, &next_ind, *size_vlmc, /*level*/0, /*Debug*/0);
  /*    --------- -> ../../io.c */
  *r = entropy(top); /* had  / log(*cardX) */

  free_node(top);/* do not leak ! */
}


void entropy2_sub(int* vlmc_vec, int* size_vlmc,
		  int* vlmc2_vec, int* size2_vlmc,
		  int* cardX,
		 /* Result : */
		 double *r)
{
    /* not at all clear what this should do.

       The main program "likestat" (formerly "draw2")
       when used without "-l"  does use entropy2(), but
       it's not so clear how...  {Martin M}
    */

  node_t *top, *t2;
  int next_ind = 0;
  top = load_tree(vlmc_vec, &next_ind, *size_vlmc, /*level*/0, /*Debug*/0);
  next_ind = 0;
  t2  = load_tree(vlmc2_vec, &next_ind, *size2_vlmc, /*level*/0, /*Debug*/0);

  *r = entropy2(top, t2);

  free_node(top);
  free_node(t2);/* do not leak ! */
}

