/* $Id: prune.c,v 1.8 2001/10/05 19:35:55 maechler Exp $ */
#include <stdlib.h> /* NULL */

#include "vlmc.h"

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
