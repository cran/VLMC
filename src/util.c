/* -- $Id: util.c,v 1.26 2024/08/14 07:34:17 maechler Exp $ */

#include <stdio.h>
#include <stdlib.h>
#include <math.h> /* log() */
#include "vlmc.h"


/*-------------- Memory Allocation ------------------
 *
 * alloc()s are all done here,
 * but	free()'s are done in  gen.c and prune.c	 --> need R_Calloc() & R_Free()
 *
 */

/* --------- create_set() & push() ------------
 *
 * These create each node's  alphabet set.
 * They are called from tree.c's main() and from generate() [gen.c].

 * An alphabet "set" is allocated in chunks of BLOCK each :
 */
#define BLOCK 16

set_t *create_set(void)
{
  set_t *set;

  if ((set = R_Calloc(1, set_t)) == NULL) {
      /* was: return NULL; */
      VLMC_ERROR("%s\n", "create_set: Couldn't allocate set [util.c]");
  }
  set->num = 0;
  set->list = R_Calloc(BLOCK, int);
  set->size = (set->list == NULL) ? 0 : BLOCK;

  return set;
}

void free_set(set_t *set)
{
    if(set != NULL) {
	if(set->list != NULL)
	    R_Free(set->list);
	R_Free(set);
    }
}

void push(set_t *set, int i)
{
    int *ptr;
    while (set->num >= set->size) {/* Extend the current set->list : */
	set->size += BLOCK;
	if ((ptr = R_Realloc(set->list, set->size, int))
	    /* (int *)realloc(set->list, sizeof(int) * (set->size + BLOCK))) */
	    == NULL) {
	    /* was: return; */
	    VLMC_ERROR("%s\n", "push(): Couldn't re-allocate set->list");
	}
	set->list = ptr;
    }
    set->list[set->num++] = i;
    return;
}


/*---------------- Node / Tree	Creation and Handling ------------------*/

node_t *create_node(int level, set_t *vals)
{
    node_t *node;
    int i;

    if ((node = R_Calloc(1, node_t)) == NULL)
	return NULL;/* allocation failed; caller (!) should complain */

    node->vals = vals;
    node->level = level;
    node->total = 0;

    for (i = 0; i < alpha_len; i++) {/*max_ : such that all can be freed*/
	node->count[i] = 0;
	node->child[i] = NULL;
    }
    return node;
}

int free_node(node_t *node)
{
    int i, res = 0;/* = success */

    if(node != NULL) {
	free_set(node->vals);
	for (i = 0; i < alpha_len; i++)
	    res += free_node(node->child[i]);
	R_Free(node);
    }
    return res;
}

node_t *copy_tree(node_t *node, int fill)
{
    /* Boolean fill : if(fill),	 also copy counts and totals */
    node_t *p;
    int i;

    p = create_node(node->level, NULL);

    if (p != NULL) {
	if (fill)
	    p->total = node->total;
	for (i = 0; i < alpha_len; i++) {
	    if (fill)
		p->count[i] = node->count[i];
	    if (node->child[i] != NULL)
		p->child[i] = copy_tree(node->child[i], fill);
	}
    } /* else : COMPLAIN */
    return p;
}

void comp_difference(node_t *node)
{
    /* RECURSIVEly `differentiate' : SUBTRACT children counts and totals.
     *
     * Called after  generate() from the fitting progam	 only
     */
    int i, j, is_leaf = -1;

    for (i = 0; i < alpha_len; i++)
	is_leaf = is_leaf && (node->child[i] == NULL);

    if (!is_leaf)
	for (i = 0; i < alpha_len; i++)
	    if (node->child[i] != NULL) {
		for (j = 0; j < alpha_len; j++)
		    node->count[j] -= (node->child[i])->count[j];
		node->total -= (node->child[i])->total;
		comp_difference(node->child[i]);
		/*============*/
	    }
}

void cumulate(node_t *node)
{
    /* RECURSIVEly `cumulate': ADD children counts and totals.
     *
     * Called from  draw_tree()	[*before* drawing]
     */
    int i, j, is_leaf = -1;

    for (i = 0; i < alpha_len; i++)
	is_leaf = is_leaf && (node->child[i] == NULL);

#ifdef DEBUG_cumulate
    Rprintf2("%*s", 2 * node->level, " ");
    Rprintf2("[%2d] cum_DBG(): is_leaf= %d; ", node->level, is_leaf);
    Rprintf(" total = %d\n", node->total);
#endif
    if (!is_leaf) {
	for (i = 0; i < alpha_len; i++)
	    if (node->child[i] != NULL) {
		cumulate(node->child[i]);
		/*======*/
		for (j = 0; j < alpha_len; j++)
		    node->count[j] += (node->child[i])->count[j];
		node->total += (node->child[i])->total;
	    }
#ifdef DEBUG_cumulate
	Rprintf2("%*s", 2 * node->level, " ");
	Rprintf2("[%2d] final node->total = %d\n", node->level, node->total);
#endif
    }
}

#define MAX(X,Y) ((X)>(Y)) ? (X) : (Y)

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

double entropy(node_t *node)
{
    /* Entropy == Log Likelihood  of a VLMC model --- RECURSIVEly
     *            --------------
     * Using probabilities of this node and all its children
     */
    int i, ct;
    double d = 0.;

    if (node->total > 0)
	for (i = 0; i < alpha_len; i++)
	    if((ct = node->count[i]) > 0)
		d += ct * log((double) ct / node->total);

    for (i = 0; i < alpha_len; i++)
	if (node->child[i] != NULL)
	    d += entropy(node->child[i]);

    return d;
}


double entropy2(node_t *node1, node_t *node2)
{
    /* Entropy	between two VLMC models --- RECURSIVEly
     * Using probabilities of this node and all its children */
    int i;
    double d = 0.;

    if (node1->total > 0)
	for (i = 0; i < alpha_len; i++)
	    if(node1->count[i] > 0)
		d += node2->count[i] *
		    log((double) node1->count[i] / node1->total);

    for (i = 0; i < alpha_len; i++)
	if ((node1->child[i] != NULL) &&
	    (node2->child[i] != NULL))
	    d += entropy2(node1->child[i],
			  node2->child[i]);
    return d;
}
