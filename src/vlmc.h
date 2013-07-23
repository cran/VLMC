/* -- $Id: vlmc.h,v 1.19 2002/02/08 08:07:41 maechler Exp $ */

#ifndef VLMC
#define VLMC

#ifdef MemTrace
# include "mcheck.h"
#endif
/* ------------- GLOBALS --------------- */

/* Constants */
#define max_alpha_len 95
/* = maximal size of alphabet, i.e. different values in data
 * This currently determines the size of each node in the tree.
 * Enlarging this will use more memory even in the binary case !
 * ---> see also ~/R/Pkgs/VLMC/TODO (7.)
 *               ------------------
 *
 * FIXME:  _node struct below should not use max_alpha_len
 * -----   but should allocate depending on *used*  alpha_len ...
 */

/* Global Variables */
extern int alpha_len;
extern char alpha[];

/* ---------- MACROS ------------------- */
#ifdef Standalone

# include <stdio.h>
# include <stdlib.h>

/* -- very simple version of REprintf(.)  ==> use multiple times if needed */
# define REprintf(fmt,x) 	fprintf(stderr,fmt,x)
# define Rprintf(fmt,x) 	printf(fmt,x)
# define Rprintf0(x) 	        printf(x)
# define Rprintf2(fmt,x,x2) 	printf(fmt,x,x2)

# define VLMC_ERROR(fmt,x)	{  fprintf(stderr,fmt,x);	exit(1); }
# define VLMC_ERROR2(fmt,x,x2)	{  fprintf(stderr,fmt,x,x2);	exit(1); }
# define VLMC_WARNING(fmt,x)	   fprintf(stderr,"Warning" fmt,x)
# define VLMC_WARNING2(fmt,x,x2)   fprintf(stderr,"Warning" fmt,x,x2)
# define VLMC_WARNING3(fmt,x,x2,x3)fprintf(stderr,"Warning" fmt,x,x2,x3)

/* S/R way of allocation */
# define S_alloc(nelem, eltsize)	malloc((eltsize)*(nelem))
# define S_realloc(p, new, old, size) 	realloc(p, (size)*(new))

# define Calloc(n, t)   (t *)  calloc( (size_t) (n), sizeof(t) )
# define Realloc(p,n,t) (t *) realloc( (void *)(p), (size_t)((n) * sizeof(t)) )
# define Free(p) 		(free( (void *)(p) ), (p) = NULL)


#else /*------------ R package or S(plus) library section ---*/

# include <S.h>

# ifdef USING_R

#  include <R.h>
#  include <R_ext/RS.h>
#  include <R_ext/PrtUtil.h>

# else /* S library section */

   /* S.h is already there ... */
#   define REprintf(fmt,x) 	fprintf(stderr,fmt,x)
#   define Rprintf(fmt,x) 	printf(fmt,x)

# endif /*-- R / S --*/

# define Rprintf0(x) 	        Rprintf(x)
# define Rprintf2(fmt,x,x2) 	Rprintf(fmt,x,x2)

# define VLMC_ERROR(fmt,x)		  error(fmt,x);
# define VLMC_ERROR2(fmt,x,x2)		  error(fmt,x,x2);
# define VLMC_WARNING(fmt,x)		warning(fmt,x)
# define VLMC_WARNING2(fmt,x,x2)	warning(fmt,x,x2)
# define VLMC_WARNING3(fmt,x,x2,x3)     warning(fmt,x,x2,x3)

#endif /*-- Standalone / R|S --*/


/* ------------- TYPE  Definitions -----------*/

/* set_t & node_t : */
typedef struct _set {
    int num, /* currently used	    length of list[] */
	size;/* currently allocated length of list[] */
    int *list;
} set_t;

/* This is the TREE : */
typedef struct _node {
  int level;
  int count[max_alpha_len];
  int total;
  struct _node *child[max_alpha_len];
  set_t *vals;
} node_t;



/* --------- VLMC Utility Functions -------------------- */

int context(int i, int level);/* uses GLOBAL data[] */

set_t *create_set(void);
void free_set(set_t *);

void push(set_t *set, int i);

node_t *create_node(int level, set_t *vals);

int free_node(node_t *node);/* free memory used by (sub)tree !*/

node_t *copy_tree(node_t *node, int fill);

void comp_difference(node_t *node);
void cumulate	    (node_t *node);

double delta(node_t *this, node_t *child);

double entropy (node_t *node);
double entropy2(node_t *node1, node_t *node2);

/* Tree Generation & Pruning */

void generate(node_t *node, int threshold);/* calls context() -> data[] */

int  prune   (node_t *node, double cutoff);

#endif
