#include "vlmc.h"

void tree_size(node_t *node, int *size);

void    save_tree(node_t *node, int *SAFE, int *free_safe,
		  int size_safe, int debug);
node_t *load_tree(const int *SAFE, int *next_ind,
		  int size_safe, int level_check, int debug);

