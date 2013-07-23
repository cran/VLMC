/*-- $Id: fitvlmc.c,v 1.19 2013/07/25 09:37:24 maechler Exp $
 * -- tree_sub.c --- Subroutine instead of main program
 * -- was ../../tree.c : tree.c,v 1.9 2000/03/17 17:13:12 maechler Exp maechler
 */

#include <string.h>

#include "vlmc.h"
#include "vlmc_io.h"
#include "subutil.h"

#include "alphabet.h" /* extern  alpha_len & alpha[] */

/*=========== GLOBAL Variables : ==============*/
int *data;
/* ---GLOBAL "parameters" : */
/* 1. alphabet : --> vlmcinit_alpha() below */
/* 2. debug */
int debug;

#define DUMP_file stdout
/* had            stderr  before */

/* This is THE TREE : built up in vlmc() and "returned" in  getvlmc()
    -- hence global : */
static node_t *top;

/* vlmc()
 * ------
 * Use uppercase argument names here,
 * not to confound with global variables and non-pointer vars
 */

/* This is the C-like version : */
void vlmc(/*const*/int *Data/*[], but need pointer !*/, int data_len,
	  int gen_thresh, /* = threshold for generation */
	  double prune_cut,/* cutoff (for pruning) */
	  int Alpha_len, /*const*/char **Alpha/* [] */,
	  int Debug,
	  const int dump_flags[3],
 /* Output : */
	  int* size_vlmc)
{

  set_t *set;
  int i;

#define do_dump		dump_flags[0]
#define dump_ct_wid	dump_flags[1]
#define dump_nmax_set	dump_flags[2]

  /*----------- Assign GLOBALS : --------------*/
  vlmcinit_alpha(Alpha_len, Alpha);
  data = Data;/* <<-- use the pointer directly */
  debug = Debug;

  /*--- Check Arguments & compute defaults ----*/
  if(gen_thresh <= 0) {
      VLMC_WARNING("threshold for VLMC generation = %d, "
		   "but must be at least 1; set to 2.\n", gen_thresh);
      gen_thresh = 2;
  }
  if(prune_cut < 0) /* in standalone program, set default here! */
      VLMC_ERROR("prune_cutoff : cutoff must be >= 0, but is %g;", prune_cut);

  if (debug) {
    /* use separate statements : simple macro for REprintf(fmt,x) */
    REprintf("vlmc: n = |data| = %d, ", data_len);
    REprintf("cutoff{prune} = %g, ", prune_cut);
    REprintf("threshold{gen} = %d\n", gen_thresh);
    REprintf("vlmc: |alphabet| = %d, ", alpha_len);
    REprintf("alphabet = %s\n", alpha);
  }
  set = create_set();
  for (i = 0; i < data_len; i++)
      push(set, i);

  top = create_node(0, set);

  if (debug) REprintf("%s", "generating... ");
  generate(top, gen_thresh);

  if (do_dump >= 2) {
      if(debug) REprintf("%s", "Dump{Tree} __before__ pruning: \n");
      dump_tree(top, /*top*/1, -1,
		alpha_len, alpha, dump_ct_wid, dump_nmax_set);
  }

  if (debug) REprintf("%s", "pruning... ");
  prune(top, prune_cut);

  if (do_dump) {
      if(debug) REprintf("%s", "Dump{Tree} __after__ pruning: \n");
      dump_tree(top, /*top*/1, -1,
		alpha_len, alpha, dump_ct_wid, dump_nmax_set);
  }

  if (debug) REprintf("%s", "computing differences['completing'] ... ");
  /*-- analog in R : from draw() counts to draw(*, cumulative=FALSE) :*/
  comp_difference(top);

  /* NEW (2002-02-08) :
   * get rid of count for very first observation which has no context at all: */
  top->count[data[0]]--;
  top->total--;

  if (debug) {
      REprintf("%s", "writing tree...\n");
      write_tree(top, debug);
  }
  size_vlmc[0] = 1;/* = alpha_len */ for(i = 1; i < 3; i++) size_vlmc[i] = 0;
  tree_size(top, /* --> */size_vlmc);
}
#undef do_dump
#undef dump_ct_wid
#undef dump_nmax_set

/* This version is called from R/S -- "_p" := has all pointers : */
void vlmc_p(int* Data, int* data_len,
	    int* gen_thresh, /* = threshold for generation */
	    double* prune_cut,/* cutoff (for pruning) */
	    int* Alpha_len, char** Alpha,
	    int* Debug,
	    int* dump_flags,
 /* Output : */
	    int* size_vlmc)
{
    vlmc(Data, *data_len,
	 *gen_thresh, *prune_cut,
	 *Alpha_len,
	 Alpha,
	 *Debug,
	 dump_flags,
	 /* Output : */
	 size_vlmc);
}

void getvlmc(int* size_vlmc, /* Output : */int* vlmc_vec)
{
    int free_s = 0;
    save_tree(top, vlmc_vec, &free_s, size_vlmc[0], /*debug*/0);

    free_node(top);/* do not leak ! */
}
