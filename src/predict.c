/* R/S callable subroutine -- similar to main program ../../predict.c */

#include "vlmc.h"
/*#include "vlmc_io.h"*/
#include "subutil.h"
#include "predict.h"

/* This is the C-like version : */
void predict_vlmc(int vlmc_vec[], int size_vlmc,
		  int m, /* = alpha_len */
		  int data[],	int data_len,
		  vlmc_pred_type pred_kind,

		  /* Output : prb_mat[] only if pred_kind has "probs" */
		  int result[],
		  int flags[],
		  double prb_mat[])
{
/* =================================================================
   Given a fitted VLMC (with |alphabet| = m)  and new data Y[1..N],

  /  pred_kind & PROBS (= ..0001 )
	 return the prediction probabilities of Y[2]..Y[N]
 xor	(based on past = relevant context) as (N-1) x m	 matrix

  \  pred_kind & CLASS (= ..0010 )

	 return the most probably class (i.e. "fitted response")
 and/or

  /  pred_kind & ID    (= ..0100 )

 xor	return the "ID" of the node / context / MC state at that observation.

  \  pred_kind & LEVEL (= ..1000 )

	return the level / depth of the MC state,
	i.e., the context length at that observation

   * =================================================================

TODO :
	- Allow "marginal" prediction [only for "probs" and "response"] for
	  initial values, instead of  NAs
*/

    int i, j, k, level, ct, ctotal, n = data_len;
    int next_ind = 0;

    node_t *top, *q1, *q2, *current;

#define Pmat(i,k)   prb_mat[i + k * n]

/* FIXME: Use functions instead of MACROs (?!)
   -----  Would need to access prb_mat[] / result[] and pass (i,m) additionally
*/
#define COMP_Pmat(qnode)					\
    ctotal = 0;							\
    for (k = 0; k < m; k++)					\
	ctotal += qnode->count[k];				\
    if(ctotal > 0)						\
	for (k = 0; k < m; k++)					\
	    Pmat(i,k) = (double) (qnode->count[k])/ctotal

#define COMP_Max(qnode) 			\
    j = 0; 					\
    ct = qnode->count[0];			\
    for (k = 1; k < m; k++)			\
	if(ct < qnode->count[k]) {		\
	    j = k ; ct = qnode->count[j]; 	\
	}					\
    if(ct > 0)					\
	result[i] = j /* in 0..(m-1) */


/* FIXME : Much Smarter and more efficient :
 * -----   Each node should have a "cumulated-counts" slot
 *         which would be NULL initially and only filled
 *         (using a version of cumulate()) when needed !!
 */
#define COMP_00(COMP_MACRO_CALL)			\
    flags[i] += 10;					\
    if(0)						\
	Rprintf2("pred(type=P./C.), data[i=%d] = %d\n",	\
		 i, data[i]);				\
    current = copy_tree(q1, /*fill = */ 1);		\
    cumulate(current);					\
    /*----- --> ../../util.c */				\
    COMP_MACRO_CALL;					\
    else { /* never seen till now */			\
	flags[i] += 1;					\
    }							\
    free_node(current);



/* effectively, the first row, prb_mat[0,] should remain untouched */

    top = load_tree(vlmc_vec, &next_ind, size_vlmc, /*level*/0, /*Debug*/0);
    /*    --------- -> ./saveload.c */

    q2 = current = NULL;/* for -Wall */

    /* i=1.. : don't touch  result[0] & Pmat(0,*) */
    for (i = 1; i < n; i++) {

	/* Find the context, descending the tree, given y[i-1], y[i-2],... :*/
	for (q1 = top, level = 1;
	     level <= i && (q2 = q1->child[data[i - level]]) != NULL;
	     q1 = q2, level++);
	/* Usually, now level <= i and found terminal node (q2 = NULL) */

	if(pred_kind & PROBS) { /* prediction probabilities: */

	    COMP_Pmat(q1);
	    else { /* (0 .. 0 | 0)  ==> use CUMULATED counts -- here only : */
		COMP_00(COMP_Pmat(current));
	    }
	}
	else if(pred_kind & CLASS) { /* index of most probable : */

	    COMP_Max(q1);
	    else { /* (0 .. 0 | 0)  ...  */
		COMP_00(COMP_Max(current));
	    }
	}
	if(pred_kind & ID) {/* "ID" of current context:*/

	    /* We define the "ID" as a unique "hash value", produced
	       from the current context, i.e., data[i-(level-1),..., i-1],
	       using the m-ary number  sum_{k=1}^{level-1} y[i-k] * m^(k-1)
	       (m = alpha.len; hence 0 <= y[] < m) :
	    */
	    ct = 1;
	    for (k = 1; k < level && k <= i; k++)
		ct = ct * m + data[i - k];
	    if(k == i && k < level) /* flag for early values w/ funny hash :*/
		flags[i] += 100;
	    result[i] = ct;
	}
	else if(pred_kind & LEVEL) { /*  depth only : */
	    result[i] = level - 1;
	}

	if(!(pred_kind && (PROBS|CLASS|ID|LEVEL)))
	    VLMC_ERROR(".C(\"pred..\"..): invalid prediction kind %d;",
		       pred_kind);

	if(q2 != NULL)
	    flags[i] += 5; /* always together with next one */
	if(level > i) {/* another flag for early values */
	  if(level == i+1) flags[i] += 50;
	  else             flags[i] += 1000;/* never seen */
	}
    }
    free_node(top);/* do not leak ! */
    /* q1 & q2  are just pointers into top! */
    /* (current) is freed above */
}

/* This version is called from R/S -- "_p" := has all pointers : */
void predict_vlmc_p(int* vlmc_vec, int* size_vlmc,
		    int* m, /* = alpha_len */
		    int* data,	int* data_len,
		    vlmc_pred_type* pred_kind,

		    /* Output : either one, chosen via pred_kind */
		    int* result,
		    int* flags,
		    double* prb_mat)
{
    predict_vlmc(vlmc_vec, size_vlmc[0],	m[0],
		 data,	data_len[0],	pred_kind[0],

		 result, flags, prb_mat);
}
