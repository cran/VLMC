/*--- Initialize the GLOBAL alphabet --- from  R/S */

#include "vlmc.h"
#include "alphabet.h" /* extern  alpha_len & alpha[] */

int alpha_len;
char alpha[max_alpha_len + 1];

void vlmcinit_alpha(int Alpha_len, char **Alpha)
{
  int i;
  if(Alpha_len > max_alpha_len)
      VLMC_ERROR2("alphabet length (%d) is larger than the current maximally allowed one (%d)\n",
		  Alpha_len, max_alpha_len);

  for(i = 0; i < Alpha_len; i++) /* Fails: alpha[] = Alpha[0]; */
      alpha[i] = Alpha[0][i];
  alpha[Alpha_len] = '\0'; /* needed, as long as alpha is GLOBAL */
  alpha_len = Alpha_len;
  return;
}

void vlmcinit(int Alpha_len)
{
  alpha_len /*global var*/ = Alpha_len;
  return;
}
