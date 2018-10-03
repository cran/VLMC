/* -- $Id: entropy.c,v 1.10 2018/10/02 16:37:37 maechler Exp $ */
#include <math.h>

#include <R.h>
#include <Rinternals.h>

#include "subutil.h"
#include "vlmc_R_pkg.h"


/* Export the routines to be called from R / S-plus.
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

SEXP vlmc_entropy(SEXP vlmc_R)
{
/* The same number --- apart from factor log(cardX) ---
   as main program   "draw -e" used to give */

  node_t *top;
  int next_ind = 0, nprot = 0;
  if (!isInteger(vlmc_R)) {
      vlmc_R = PROTECT(coerceVector(vlmc_R, INTSXP)); nprot++;
  }

  top = load_tree(INTEGER(vlmc_R), &next_ind, LENGTH(vlmc_R),
/*      --------, level=*/ 0, /*Debug*/ 0);

  double r = entropy(top); /* had  / log(*cardX) */
  free_node(top);/* do not leak ! */
  if(nprot) UNPROTECT(nprot);
  return ScalarReal(r);
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

SEXP vlmc_entropy2(SEXP vlmc_1, SEXP vlmc_2)
{
    /* not at all clear what this should do.

       The main program "likestat" (formerly "draw2")
       when used without "-l"  does use entropy2(), but
       it's not so clear how...  {Martin M}
    */

  int next_ind = 0, nprot = 0;
  if (!isInteger(vlmc_1)) {
      vlmc_1 = PROTECT(coerceVector(vlmc_1, INTSXP)); nprot++;
  }
  if (!isInteger(vlmc_2)) {
      vlmc_2 = PROTECT(coerceVector(vlmc_2, INTSXP)); nprot++;
  }

  node_t *top = load_tree(INTEGER(vlmc_1), &next_ind, LENGTH(vlmc_1),
			  /*level*/0, /*Debug*/0);
  next_ind = 0;
  node_t *t2  = load_tree(INTEGER(vlmc_2), &next_ind, LENGTH(vlmc_2),
			  /*level*/0, /*Debug*/0);

  double r = entropy2(top, t2);

  free_node(top);
  free_node(t2);/* do not leak ! */

  if(nprot) UNPROTECT(nprot);
  return ScalarReal(r);
}

