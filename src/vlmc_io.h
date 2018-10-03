/*-- $Id: vlmc_io.h,v 1.12 2018/10/03 09:16:40 maechler Exp $*/
#include <stdio.h>

#include "vlmc.h"

void draw_tree(node_t *node, node_t *super, int a, int is_last,
	       int kind, int show_hidden, int do_delta, int debug);

void dump_tree(node_t *node, int is_top, int ia,
	       int cardX/* = alpha_len */, const char *alphabet,
	       int ct_wid, int nmax_set);
void write_tree(node_t *node, int debug);

#ifdef VLMC_USING_FILES
void f_dump_tree(node_t *node, FILE *file, int is_top, int ia,
		 int cardX/* = alpha_len */, const char *alphabet,
		 int ct_wid, int nmax_set);
void f_write_tree(node_t *node, FILE *file, int debug);

node_t *read_tree(FILE *file, int level_check, int debug);
#endif


void read_data(int *data, int *data_len);/* assigns its args */
