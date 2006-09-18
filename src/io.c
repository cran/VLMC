/* -- $Id: io.c,v 1.19 2001/10/17 12:52:14 maechler Exp $ */
#include <stdio.h>
#include <string.h>

#include "vlmc.h"
#include "vlmc_io.h"

/*
  Called from R/S interface subroutine  VLMC/src/drawvlmc.c

  Called from main program  ./draw.c	 as

   top = read_tree(stdin, 0, debug);
   cumulate (top);
   draw_tree(top, NULL,  -1,  0,     kind);
                  super  ia  is_last
*/
#define MAX_DEPTH 128

void draw_tree(node_t *node, node_t *super, int ia,
	       int is_last, int kind, int show_hidden, int do_delta, int debug)
{
    /* __recursive__ function for drawing a VLMC tree (to stdout) */

    static short lev_fini[MAX_DEPTH];/* global in all recursive calls */

    int i, lev = (node == NULL) ? super->level + 1 : node->level,
	nr_kids = 0, do_mark;

    if (debug) {
/* REprintf("draw_tree(*,*,ia=%d, is_last=%d, kind=%d)\n", ia, is_last, kind);*/
	REprintf("draw_tree(*,*,ia=%d, ", ia);
	REprintf("is_last=%d, ", is_last);
	REprintf("kind=%d, ", kind);
	REprintf("show_h.=%d)\n", show_hidden);
    }
    if (kind >= 2) {
	/*
	  For that, the current node must "know" not only its level,
	  but also
	  1) if it's the last on the current level (then "+", else "`")
	  2) which levels "above" have not been the last ones (then put "|")
	*/
	if(is_last)
	    lev_fini[super->level]++;
    }

    if(lev > MAX_DEPTH)
	VLMC_ERROR2("draw_tree(): node->level = %d > MAX_DEPTH = %d!\n"
		    "\t do you want an even higher order Markov Chain?\n"
		    "\t --> consider recompiling (after increasing MAX_DEPTH) ...\n",
		   lev, MAX_DEPTH);
    for (i = 0; i < lev; i++)
	if(kind == 0) /* slightly improved */
	    Rprintf0(i < lev - 1 ? "    " : " `--");
	else if(kind == 1) /* old way */
	    Rprintf0(i == 0      ? " +--" : "-+--");
	else /* kind >= 2: try to be smart... */
	    Rprintf0(i < lev - 1
		     ? (lev_fini[i] ? "    " : " |  ")
		     : (is_last	    ? " `--" : " +--"));

    Rprintf("[%c]-(", (ia < 0) ? 'x' : alpha[ia]);

    if(node == NULL) {
	Rprintf0("___)\n");
	return;
    }
    /* ELSE : "real node" */

    for (i = 0; i < alpha_len; i++)
	Rprintf(" %d", node->count[i]);
    Rprintf("| %d)", node->total);
    if (do_delta && super != NULL)
	Rprintf(" <%.2f>", delta(super, node));
    do_mark = kind >= 3 && kind % 2;
    if(!do_mark && show_hidden >=3) {
	do_mark++;
	VLMC_WARNING2("show_hidden = %d >=3, but kind is %d;"
		      " --> setting kind := 3\n",
		      show_hidden, kind);
	kind = 3;
    }
    if(do_mark) {/* kind = 3, 5, .. */
	/* Now, print a ``mark'' for end-nodes and those
	 * "counting" for context size.
	 * -> use code (ideas) from tree_size() VLMC/src/saveload.c
	 */
	for (i = 0; i < alpha_len; i++)
	    if(node->child[i] != NULL)
		nr_kids++;
	if(nr_kids) {
 	    if(nr_kids == alpha_len)
 		Rprintf0("-F"); /* All offspring: quite rare (above is rule)*/
	    else /* nr_kids < alpha_len */ if (show_hidden) {
		if (show_hidden >= 2) {
		    Rprintf0("-");
		    for(i = nr_kids; i < alpha_len; i++) /* each xtra child*/
			Rprintf0(".");
		}
		else /* show_hidden = 1 */
		    Rprintf0("-:");/* was "++" */
	    }
	}
	else /* leaf */
	    Rprintf0("-T"); /* was "-*"; "T" is for "Terminal node" */
    }
    Rprintf0("\n");

    if(kind >= 2) {
	for (i = lev; i < MAX_DEPTH; i++)
	    lev_fini[i] = 0;
	/* For smart `kind',
	   need to find out which of the children will be the last : */
	if(show_hidden >= 3)
	    is_last = alpha_len - 1;
	else
	    for (i = 0; i < alpha_len; i++)
		if (node->child[i] != NULL) is_last = i;
    }
    for (i = 0; i < alpha_len; i++)
	if ((show_hidden >= 3 && nr_kids) || node->child[i] != NULL)
	    draw_tree(node->child[i], node, i, i == is_last,
		      kind, show_hidden, do_delta, debug);
}/* {draw_tree} */

void dump_tree(node_t *node, FILE *file, int is_top, int ia,
	       int cardX/* = alpha_len */, const char *alphabet,
	       int ct_wid, int nmax_set)
{
    /* __recursive__ function for dumping all content
       of a VLMC tree to file
    */
    int i, num, cut, ct1 = ct_wid + 1;
    set_t *myset;

    if(is_top) { /* at the top : Print a header line */
	fprintf(file, "Lev Ch|");
	for (i = 0; i < cardX; i++)
	    fprintf(file, " %*c", ct_wid, alphabet[i]);
	fprintf(file, " | %*s | %*s %*s :",
	       ct1, "tot", ct1, "num", ct1, "size");
	fprintf(file, " ..{set->list}..\n");
	fprintf(file, "------+-");
	for(i = cardX*ct_wid + 3 * ct1 + 31; i > 0; i--)
	    fputc('-', file);
	fputc('\n', file);
    }

    /* -------- Print ONE line per Node ------------ */
    fprintf(file, "%3d ", node->level);
    fprintf(file, "%1c |", (ia < 0) ? 'x' : alphabet[ia]);

    for (i = 0; i < cardX; i++)
	fprintf(file, " %*d", ct_wid,	   node->count[i]);
    fprintf(file, " | %*d |", ct1, node->total);

    /* the "vals set" : --- only non-NULL after generate() !! */
    if((myset = node->vals) != NULL) {
	fprintf(file, " %*d %*d :", ct1, (num = myset->num), ct1, myset->size);
	if (num > nmax_set) { num = nmax_set; cut = 1; } else cut = 0;
	for (i = 0; i < num; i++)
	    fprintf(file, " %d", myset->list[i]);
	if(cut) fprintf(file, " ..");
    } else  fprintf(file, " <empty>");
    fprintf(file, "\n");

    /* -------- Now do all the child nodes : ----------- */
    for (i = 0; i < cardX; i++)
	if (node->child[i] != NULL)
	    dump_tree(node->child[i], file, 0, i,
		      cardX, alphabet, ct_wid, nmax_set);
}/* dump_tree */

void write_tree(node_t *node, FILE *file, int debug)
{
    /* Write the "fitted VLMC" in 'node' to file.
     * ___Recursive___ Function
     *
     * uses GLOBAL alpha[] & alpha_len
     */
    int i;

    if (node == NULL) { /* leaf */
	if (debug) REprintf("%s","- ");
#ifndef ALTERNATIVE
	fputs("-1\n", file);
#else
	fputs("-1 ", file);
#endif
    }
    else {
	if (debug) REprintf("[%d]", node->level);

	if (node->level == 0) { /* first line = alphabet */
	    fputs(alpha, file);
	    fputc('\n', file);
	}

#ifndef ALTERNATIVE
	fprintf(file, "%d", node->level);
#else
	fprintf(file, "\n%*d", node->level+1, node->level);
#endif
	for (i = 0; i < alpha_len; i++)
	    fprintf(file, " %d", node->count[i]);
	fputc('\n', file);

	for (i = 0; i < alpha_len; i++)
	    write_tree(node->child[i], file, debug);
	if (debug) REprintf("%s","\n");
    }
}

node_t *read_tree(FILE *file, int level_check, int debug)
{
    /* Read a "fitted VLMC" from file and return it as tree.
     * ___Recursive___ Function :  level_check = level in tree.
     *
     * assigns GLOBAL alpha[], alpha_len
     */
    int i, level;
    node_t *node;

    if (level_check == 0) {/* very first line : Read alphabet */
	fscanf(file, "%*s", alpha, max_alpha_len);
	alpha_len = strlen(alpha);
    }
    fscanf(file, "%d", &level); /* Read current level */
    if (debug)
	REprintf("[%d]", level);
    if (level >= 0) { /* non-end */
	if (level != level_check)
	    VLMC_ERROR("error:	malformed tree at level %d\n", level_check);

	if ((node = create_node(level, NULL)) != NULL) {
	    /*	    ===========	 alloc'ates */
	    node->total = 0;
	    /* read the count[i] : */
	    for (i = 0; i < alpha_len; i++) {
		fscanf(file, "%d", &(node->count[i]));
		node->total += node->count[i];
	    }
	    /* node ->	 total == sum(i ; count[i] ) */
	    for (i = 0; i < alpha_len; i++)
		node->child[i] = read_tree(file, level_check + 1, debug);
	    /*			 =========	 --------------- */
	    if(debug && level_check == 0) /* top-level end */
		REprintf("%s\n","");

	    return node;
	}
	else {
	    VLMC_WARNING("create_node(%d)= NULL :  alloc problem ?", level);
	    return NULL;
	}
    }
    else /* level < 0 :	 end */
	return NULL;
}
