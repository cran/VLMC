#include "vlmc.h"
#include "subutil.h"

/* These are similar to write_tree, read_tree  in  ../../io.c :
   -- "Read" and "Write" from integer array :
*/

void tree_size(node_t *node, int *size)
{
/* Compute "all possible" sizes of the fitted VLMC tree node :

 *	size[0] := #{total number of integers needed for storage}
 *	size[1] := #{total number of end_nodes, i.e. leaves }
 *	size[2] := df := #{size of tau_c, the context}
 *		 = size[1] + #{"hidden nodes"}
 *	size[3] := k = order of Markov Chain = maximal depth of tree
 */
    int i, lev, nr_kids, non_leaf = 0;

    size[0]++; /* "node" */
    if (node != NULL) { /* non-leaf node */
	lev = node->level;
	if(lev > size[3]) size[3] = lev;
	/*if (lev ==  0) --> would add 1 for alphabet size */

	for (i = 0; i < alpha_len; i++)
	    if((non_leaf = node->child[i] != NULL)) break;

	if(non_leaf) {
	    nr_kids = 0;
	    for (i = 0; i < alpha_len; i++) {
		size[0]++;/* count */
		if(node->child[i] != NULL) nr_kids++;
		tree_size(node->child[i], size);
	    }
	    if(nr_kids < alpha_len) /* have an extra "invisible" node */
		size[2]++;
	}
	else { /* leaf */
	    size[0] += 2 * alpha_len; /* one for each (node + count) */
	    size[1]++;
	    size[2]++;
	}
    }
} /* tree_size */

void save_tree(node_t *node, int *SAFE, int *free_safe,
	       const int size_safe, const int debug)
{
    /*	__Recursively__ write the VLMC subtree in node to SAFE[] vector.
     *
     * *free_safe  is the smallest index i such that  SAFE[i] is still free.
     * size_safe   is the total (allocated) size of SAFE.
     *
     * NOTE: The alphabet is NOT saved here, only its size
     */
    int i, lev;

#define Save(val)						\
    if(*free_safe < size_safe)					\
	SAFE[(*free_safe)++] = val;				\
    else							\
	VLMC_ERROR("save_tree(): SAFE is not large enough (%d)\n", size_safe);

/* BEGIN */
    if (node == NULL) { /* leaf */
	if (debug) REprintf(" {%s}", "-");
	Save(-1);
    }
    else { /* non-leaf node */
	lev = node->level;
	if (debug) {
	    for(i=0; i < lev; i++) REprintf("%2c", ' '); REprintf("{%d}", lev);
	}

	if (lev == 0) {/* very first : alphabet size */
	    if (debug) {
		REprintf(" (free,size) = (%d, ", *free_safe);
		REprintf("%d)\n", size_safe);
	    }
	    Save(alpha_len);
	}
	Save(lev);
	for (i = 0; i < alpha_len; i++)
	    Save(node->count[i]);

	for (i = 0; i < alpha_len; i++)
	    save_tree(node->child[i], SAFE, free_safe, size_safe, debug);
    }
} /* save_tree */

node_t *load_tree(const int *SAFE, int *next_ind,
		  int size_safe, int level_check, int debug)
{
    /* Load a "fitted VLMC" from SAFE[] vector and return it as tree.
     * ___Recursive___ Function :  level_check = level in tree.
     *
     * --- "analog of read_tree()" ---
     */
    int i, level, n;
    node_t *node;

#define Next_SAFE()	SAFE[(*next_ind)++];				\
    if (*next_ind > size_safe)						\
	VLMC_ERROR("load_tree(): SAFE is not large enough (%d)\n",	\
		   size_safe);

    if (level_check == 0) {/* very first line : Read alphabet */
	alpha_len = Next_SAFE();
	if(debug)
	    REprintf("load_tree: alpha_len = %d\n", alpha_len);
    }
    level = Next_SAFE();

    if (level >= 0) { /* non-end */
	if (level != level_check)
	    VLMC_ERROR("error:	malformed tree at level %d\n", level_check);

	if ((node = create_node(level, NULL)) != NULL) {
	    /*	    ===========	 alloc'ates */
	    if(debug) REprintf("  l_t [%d]: ", level);

	    node->total = 0;
	    /* read the count[i] : */
	    for (i = 0; i < alpha_len; i++) {
		n = Next_SAFE();
		node->count[i] = n;
		node->total += n;
	    }
	    /* node ->	 total == sum(i ; count[i] ) */
	    if(debug) REprintf("  tot %d\n", node->total);

	    for (i = 0; i < alpha_len; i++)
		node->child[i] =
		    load_tree(SAFE, next_ind, size_safe, level_check +1, debug);
	    /*	    =========				 --------------- */

	    return node;
	}
	else {
	    VLMC_WARNING("create_node(%d)= NULL :  alloc problem ?", level);
	    return NULL;
	}
    }
    else /* level < 0 :	 end */
	return NULL;
} /* load_tree */
