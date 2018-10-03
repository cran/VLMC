#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

#include "vlmc_R_pkg.h"
// --> "vlmc.h"

#define CDEF(name)  {#name, (DL_FUNC) &name, sizeof(name ## _t)/sizeof(name ## _t[0]), name ##_t}
#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

/* "FIXME": define drap_p_t  headers and use  CDEF(....),

   as e.g., in package  cluster
*/

static const R_CMethodDef CEntries[] = {
    {"draw_p",         (DL_FUNC) &draw_p,         10},
    {"getvlmc",        (DL_FUNC) &getvlmc,         2},
    {"predict_vlmc_p", (DL_FUNC) &predict_vlmc_p,  9},
    {"vlmc_p",         (DL_FUNC) &vlmc_p,          9},
    {NULL, NULL, 0}
};

static const R_CallMethodDef CallEntries[] = {
    CALLDEF(vlmc_entropy,  1),
    CALLDEF(vlmc_entropy2, 2),
    CALLDEF(vlmc_sim,      2),
    {NULL, NULL, 0}
};

void R_init_VLMC(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
