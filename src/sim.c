/* -- $Id: sim.c,v 1.5 2001/02/22 13:05:28 maechler Exp $
   R/S callable subroutine -- similar to main program ../../simvlmc.c 
*/
#include "vlmc.h"
#include "subutil.h"

/* try to do things to be (somewhat) portable between S & R ... */
#include <S.h>
/* instead of
 #include <R_ext/Random.h>
*/

void sim_vlmc(int* vlmc_vec,
	      int* size_vlmc,
	      int* m, /* = alpha_len */
	      /* Result, using 0:(m-1) as alphabet : */
	      int* data_len,
	      int* y)
{
/* Given a fitted VLMC (with |alphabet| = m), simulate a new series y[1..N],
   where N = data_len */

    int i, j, count, next_ind = 0;
    double r;
    node_t *top, *this, *temp;
    long unused;

    top = load_tree(vlmc_vec, &next_ind, *size_vlmc, /*level*/0, /*Debug*/0);

    seed_in(&unused);

    for (i = 0; i < *data_len; i++) {
	/* Find the context, descending the tree, given y[i-1], y[i-2],... : */
	for (j = 1, this = top;
	     j <= i && (temp = this->child[y[i - j]]) != NULL;
	     j++, this = temp) ;

	r = (double) this->total * unif_rand();
	count = 0;
	for (j = 0; j < *m; j++) {
	    count += this->count[j];
	    if (r <= count) {
		y[i] = j;	break;
	    }
	}
    }
    seed_out(&unused);

    free_node(top);/* do not leak ! */
}


