#include "vlmc_util.h"

/* Global Variables */
extern int THRESH;
extern double cutoff;

/* Declaration of Tree Generation Functions */

void count_alpha(node_t *node);

void generate(node_t *node);

int prune(node_t *node);
