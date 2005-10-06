## R >= 2.2.0 has a simulate() *generic* in 'stats'

if(!exists("simulate", mode = "function")) {
    simulate <- function (object, nsim = 1, seed = NULL, ...)
        UseMethod("simulate")
}

## -- simulate() *method* {since Sept.2005}  (instead of function):
## -- following simulate.lm() in .../R/src/library/stats/R/lm.R
simulate.vlmc <-
    function(object, nsim = 1, seed = NULL,
             n = object$n, n.start = 64 * object$size["context"],
             integer.return = FALSE, keep.RSeed = TRUE, ...)
{
    ## Author: Martin Maechler, Date: 10 Apr 2000
    if(!is.vlmc(object))
	stop("first argument must be a \"vlmc\" object; see ?vlmc")
    if(length(list(...))) warning("ignoring extraneous arguments")
    ivlmc <- object $ vlmc

    if(0 > (n <- as.integer(n)))
        stop("required output-length n must be >= 0")
    n <- as.integer(n + n.start)
    if(keep.RSeed) { # behave as generic `?simulate' says
        if(!exists(".Random.seed", envir = .GlobalEnv))
            runif(1)                 # initialize the RNG if necessary
        if(is.null(seed))
            RNGstate <- .Random.seed
        else {
            R.seed <- .Random.seed
            set.seed(seed)
            RNGstate <- structure(seed, kind = as.list(RNGkind()))
            on.exit(assign(".Random.seed", R.seed, envir = .GlobalEnv))
        }
    } ## else: back-compatible to older 'simulate.vlmc'

    m <- as.integer(object $ alpha.len)
    iy <- .C("sim_vlmc",
             vlmc.vec	= as.integer(ivlmc),
             size	= length(ivlmc),
             m          = m,
             data.len	= n,
             y 		= integer(n),
             DUP	= FALSE,
             PACKAGE	= "VLMC")$y[-(1:n.start)]

    ans <- if(integer.return) iy else strsplit(object$alpha, NULL)[[1]][1 + iy]
    if(keep.RSeed)
        attr(ans, "seed") <- RNGstate
    ans
}
