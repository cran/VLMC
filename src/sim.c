/* -- $Id: sim.c,v 1.7 2014/10/04 15:21:01 maechler Exp $
   R/S callable subroutine -- similar to main program ../../simvlmc.c
*/
#include "vlmc.h"
#include "subutil.h"

#include <Rinternals.h>

/* try to do things to be (somewhat) portable between S & R ... */
#include <S.h>
/* instead of
 #include <R_ext/Random.h>
*/

SEXP vlmc_sim(SEXP vlmc_R, SEXP nsim_)
{
/* Given a fitted VLMC (with |alphabet| = m), simulate a new series y[1..N],
   where N = data_len */

    int N = asInteger(nsim_), next_ind = 0, nprot = 1;
    if (!isInteger(vlmc_R)) {
	vlmc_R = PROTECT(coerceVector(vlmc_R, INTSXP)); nprot++;
    }

    SEXP res = PROTECT(allocVector(INTSXP, N)); // the result
    int *y = INTEGER(res),
	m = INTEGER(vlmc_R)[0]; // =  |alphabet|

    node_t *top = load_tree(INTEGER(vlmc_R), &next_ind, LENGTH(vlmc_R),
		    /*level*/ 0, /*Debug*/ 0);
    long unused;
    seed_in(&unused);/* i.e. GetRNGstate() */

    for (int i = 0; i < N; i++) {
	/* Find the context, descending the tree, given y[i-1], y[i-2],... : */
	node_t *this, *temp;
	int j;
	for (j = 1, this = top;
	     j <= i && (temp = this->child[y[i - j]]) != NULL;
	     j++, this = temp) ;

	int count = 0;
	double r = (double) this->total * unif_rand();
	for (j = 0; j < m; j++) {
	    count += this->count[j];
	    if (r <= count) {
		y[i] = j;	break;
	    }
	}
    }
    seed_out(&unused);/* i.e. PutRNGstate() */

    free_node(top);/* do not leak ! */
    UNPROTECT(nprot);
    return res;
}


