/*-- $Id: vlmc_io.h,v 1.10 2001/10/03 07:56:35 maechler Exp $*/
#include <stdio.h>

void draw_tree(node_t *node, node_t *super, int a, int is_last,
	       int kind, int show_hidden, int do_delta, int debug);

void dump_tree(node_t *node, FILE *file, int is_top, int ia,
	       int cardX/* = alpha_len */, const char *alphabet,
	       int ct_wid, int nmax_set);

void   write_tree(node_t *node, FILE *file, int debug);
node_t *read_tree(FILE *file, int level_check, int debug);

void read_data(int *data, int *data_len);/* assigns its args */
