#include "vlmc.h"

// for vlmc_pred_type  (was '#include "predict.h"') :
typedef enum {
    PROBS = 1,
    CLASS = 2,
    ID    = 4,
    LEVEL = 8
} vlmc_pred_type;


// .C() calls from ../R : ---------------------------------------

// in drawvlmc.c :
void draw_p(int* vlmc_vec, int* size_vlmc,
	    int* Alpha_len, /*const*/ char** Alpha/*[]*/,
	    int* flag, int* Debug,
	    int* kind, int* show_hidden, int* do_cumulate, int* do_delta);

// in fitvlmc.c :
void getvlmc(int* size_vlmc, /* Output : */int* vlmc_vec);

void vlmc_p(int* Data, int* data_len,
	    int* gen_thresh, /* = threshold for generation */
	    double* prune_cut,/* cutoff (for pruning) */
	    int* Alpha_len, char** Alpha,
	    int* Debug,
	    int* dump_flags,
	    /* Output : */
	    int* size_vlmc);

// in predict.c :
void predict_vlmc_p(int* vlmc_vec, int* size_vlmc,
		    int* m, /* = alpha_len */
		    int* data, int* data_len,
		    vlmc_pred_type* pred_kind,
		    /* Output : either one, chosen via pred_kind */
		    int* result,
		    int* flags,
		    double* prb_mat);


// .Call() calls from ../R : ---------------------------------

// in  entropy.c :
SEXP vlmc_entropy(SEXP vlmc_R);
SEXP vlmc_entropy2(SEXP vlmc_1, SEXP vlmc_2);

// in  sim.c :
SEXP vlmc_sim(SEXP vlmc_R, SEXP nsim_);


