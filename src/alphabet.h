/* The global alphabet : */

#include "vlmc.h" /* max_alpha_len */

extern int alpha_len;
extern char alpha[max_alpha_len + 1];

void vlmcinit_alpha(int Alpha_len, char **Alpha/* const char* Alpha[]*/);
void vlmcinit      (int Alpha_len);
