/* -- $Id: gen.c,v 1.13 2002/02/08 17:58:23 maechler Exp $ */
#include <stdio.h>
#include <stdlib.h>

#include "vlmc.h"

static void count_alpha(node_t *node)
{
  /* given node->vals, compute  count[] and total */
  set_t *vals;
  int i;

  for (i = 0; i < alpha_len; i++)
    node->count[i] = 0;

  vals = node->vals;
  for (i = 0; i < vals->num; i++)
    node->count[context(vals->list[i], 0)]++;

  node->total = vals->num;

  return;
}

void generate(node_t *node, int threshold)
{
    /* RECURSIVEly build up the vlmc tree.
     *
     * Uses data[] implicitly via context().
     */

    set_t *this_set, *child_set[max_alpha_len];
    int i, level;

    count_alpha(node);

    this_set = node->vals;
    for (i = 0; i < alpha_len; i++)
	child_set[i] = create_set();

    level = node->level + 1;

    for (i = 0; (i < this_set->num) && (this_set->list[i] < level); i++) ;

    for (; (i < this_set->num); i++)
	push(child_set[context(this_set->list[i], level)], this_set->list[i]);

    for (i = 0; i < alpha_len; i++)
	if (child_set[i]->num >= threshold) {
	    node->child[i] = create_node(level, child_set[i]);
	    /*		     =========== alloc'ates;
	     *		child_set[i] will be freed together with node->child[i]
	     */
	    generate(node->child[i], threshold);
	    /*----*/
	} else
	    free_set(child_set[i]);
}




