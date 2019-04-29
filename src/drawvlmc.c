/* -- $Id: drawvlmc.c,v 1.12 2018/10/02 16:37:37 maechler Exp $
 * -- draw_sub.v --- Subroutine instead of main program
 * -- was ../../draw.c,v 1.9 2000/03/17 17:13:12 maechler
*/
#include <stdio.h>
#include <math.h>
#ifndef Macintosh
# include <unistd.h>
#endif

#include "vlmc_io.h"
#include "subutil.h"

#include "alphabet.h"

#include "vlmc_R_pkg.h"

/* To be called from R/S : */

/* This is the C-like version : */
void draw(const int vlmc_vec[], int size_vlmc,
	  int Alpha_len, /*const*/ char** Alpha/*[]*/,
	  int flag, /* -e  in main program */
	  int Debug,/* -d */
	  int kind,  /* -k <kind> */
	  int show_hidden, /* n.a. */
	  int do_cumulate,
	  int do_delta
    )
{
  node_t *top;
  int next_ind = 0;

  if(Debug) {
      REprintf(" draw(vlmc_vec, size = %d,", size_vlmc);
      REprintf("|alpha| = %d,", Alpha_len); REprintf("flag = %d,", flag);
      REprintf("debug = %d,", Debug);       REprintf("kind = %d)\n", kind);
  }
  /*----------- Assign global alphabet : */
  vlmcinit_alpha(Alpha_len, Alpha);

  if(Debug)
      REprintf(" draw(..) -- before load_tree(): alpha = «%s»\n", alpha);

  top = load_tree(vlmc_vec, &next_ind, size_vlmc, /*level*/0, Debug);
  /*    --------- -> ./saveload.c */

  if (!flag)
      Rprintf("%f\n", entropy(top) / log(alpha_len));
  else {
      if(do_cumulate)
	  cumulate(top);
      else if(do_delta)
	  VLMC_WARNING("%s",
		       "cumulative = F, but do.delta = T does NOT make sense");
      draw_tree(top, NULL, /*ia*/-1, /*is_last*/0, kind, show_hidden, do_delta,
     /*------- -> ./io.c */Debug);
  }
  free_node(top);/* do not leak ! */
}

/* This version called from R/S -- "_p" := has all pointers : */
void draw_p(int* vlmc_vec, int* size_vlmc,
	    int* Alpha_len, /*const*/ char** Alpha/*[]*/,
	    int* flag, int* Debug,
	    int* kind, int* show_hidden, int* do_cumulate, int* do_delta)
{
    draw(vlmc_vec, *size_vlmc,
	 *Alpha_len, Alpha,
	 *flag, *Debug,
	 *kind, *show_hidden, *do_cumulate, *do_delta);
}
