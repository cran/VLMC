/* $Id$
 * cutoffs() -- return a vector of all active cutoff values
 *              for a given fitted VLMC, i.e. the delta values that are
 *		to be active in cutoff-comparison when pruning the tree
 *
 * Actually plan to compute the likelihoods and "sizes" simultaneously,
 * such that finally enabling AIC directly here...
*/

#include <math.h>
#include <unistd.h>

#include "vlmc.h"
#include "vlmc_io.h"
#include "subutil.h"

#include "alphabet.h"

/* To be called from R/S : */

/* This is the C-like version : */
void cutoffs(const int vlmc_vec[], int size_vlmc,
	  int cardX,
	  int flag, /* -e  in main program */
	  int Debug,/* -d */
	  int kind) /* -k <kind> */
{
  node_t *top;
  int next_ind = 0;
  int size[4];/* see tree_size() in ./saveload.c */

  if(Debug) {
      REprintf(" cutoffs(vlmc_vec, size = %d,", size_vlmc);
      REprintf("|alpha| = %d,", cardX); REprintf("flag = %d,", flag);
      REprintf("debug = %d,", Debug);       REprintf("kind = %d)\n", kind);
  }

  vlmcinit(cardX);/* assign global alpha_len */

  top = load_tree(vlmc_vec, &next_ind, size_vlmc, /*level*/0, Debug);
  /*    --------- -> ./saveload.c */

  tree_size(top, /* --> */ size);

  cumulate(top);/* needed for delta() */

  /* was draw_tree() in ./drawvlmc.c : */
/*----------
  --  cutoffs_tree(top, NULL, ..... --*/


  free_node(top);/* do not leak ! */
}

void active_deltas(node_t *this)
{

}

#ifdef ______NOT__HERE______just__to_look_at

  double delta(node_t *this, node_t *child)
  {
  #define epsilon 1e-7
    int i, ct;
    double this_prob, child_prob, d = 0.;

    for (i = 0; i < alpha_len; i++)
	if((ct = child->count[i]) > 0) {
	    this_prob  = MAX((double) this->count[i] / this->total, epsilon);
	    child_prob = (double)ct / child->total;
	    d += ct * log(child_prob / this_prob);
	}
    return d;
  }


  int prune(node_t *node, double cutoff)
  {
  /* RECURSIVEly prune the current node;
   * return "TRUE" when the current node has become a leaf, ie. has no children.
   *
   * Note that this is called after generate() and BEFORE comp_difference()
   *
   * Whenever we prune an existing vlmc tree, we'll first have to
   * cumulate() before calling delta() and hence prune()
   */
    node_t *p;

    int i;

    for (i = 0; i < alpha_len; i++)
	if((p = node->child[i]) != NULL && prune(p, cutoff)
	   && delta(node, p) <= cutoff) {/*----------------*/
	    /*------------- "<=" : useful for cutoff=0; had "<" before */
	  free_node(p);
	  node->child[i] = NULL;
	}

    for(i = 0; i < alpha_len; i++)
	if (node->child[i] != NULL)
	    return 0;
    /*else */
    return 1;
  }

#endif

/* This version called from R/S -- "_p" := has all pointers : */
void cutoffs_p(int* vlmc_vec, int* size_vlmc,
	       int* cardX,
	       int* flag, int* Debug, int* kind)
{
    cutoffs(vlmc_vec, *size_vlmc,
	    *cardX, *flag, *Debug, *kind);
}
