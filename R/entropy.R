## Purpose: Entropy of a fitted "vlmc" object, see ?vlmc
## ------------------------------------------------------------------------
## $Id: entropy.R,v 1.9 2002/02/05 09:14:34 maechler Exp $
## Author: Martin Maechler, Date:  5 Apr 2000, 18:31

## Entropy  ===  Log[Likelihood] !
entropy <- function(object)
{
    if(!is.vlmc(object))
        stop("first argument must be a \"vlmc\" object; see ?vlmc")
    ivlmc <- object $ vlmc
    .C("entropy_sub",
       vlmc.vec     = as.integer(ivlmc),
       size         = length(ivlmc),
       alpha.len    = as.integer(object$ alpha.len),
       r = double(1),
       DUP = FALSE,
       PACKAGE = "VLMC")$r
}

logLik.vlmc <- function(object, ...)
{
    r <- entropy(object)
    attr(r, "df") <- (object$alpha.len - 1) * unname(object$size["context"])
    class(r) <- "logLik"
    r
}


### Maybe -- rather call this on 2 `vlmc' objects
entropy2 <- function(ivlmc1, ivlmc2, alpha.len = ivlmc1[1])
{
    ## Purpose: Entropy between two vlmc (sub) trees, see ?vlmc
    ## ------------------------------------------------------------------------
    ## Author: Martin Maechler, Date:  10 Apr 2000

###-- untested -- maybe non-sense
    if(0 >= (alpha.len <- as.integer(alpha.len)))
        stop("alphabet length must be >= 1")
    if(ivlmc2[1] != alpha.len)
        stop("alphabet length differs for 2nd arg")

    ##-- no checks, we really use the integer vectors themselves ..
    .C("entropy2_sub",
       vlmc.vec     = as.integer(ivlmc1), size = length(ivlmc1),
       vlmc2.vec    = as.integer(ivlmc2), size = length(ivlmc2),
       alpha.len    = alpha.len,
       r = double(1),
       DUP = FALSE,
       PACKAGE = "VLMC")$r
}

## Purpose: Akaike Information Criterion for VLMC objects
## -------------------------------------------------------------------------
## Arguments: VLMC object
## -------------------------------------------------------------------------
## Author: Martin Maechler, Date: 21 Dec 2000

##Now in R:  AIC <- function (object, ...) UseMethod()

## for R versions < 1.4:
if(paste(R.version$major, R.version$minor, sep=".") < 1.4)
    AIC.vlmc <- (AIC.lm)#.Alias
