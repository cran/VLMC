### How can I make functions from a package share a common utility ?
### This fails (functions do not end in package) :
##  local({ ss <- function(x) strsplit(x,NULL)[[1]]

int2alpha <- function(i, alpha)
{
    ## {0,1,..} |--> "alphabet" representation of discrete t.s.
    (strsplit(alpha,NULL)[[1]])[1:1 + i]
}
alpha2int <- function(x, alpha)
{
    ## (single) character |--> {0,1,..}  representation of discrete t.s.
    match(x, strsplit(alpha,NULL)[[1]]) - 1:1
}

int2char <- function(i, alpha)
{
    ## {0,1,..} |--> "alphabet" representation -- as 1 string --
    paste(int2alpha(i,alpha), collapse="")
}
char2int <- function(x, alpha)
{
    ## 1-string |--> {0,1,..}  representation of discrete t.s.
    ss <- function(x) strsplit(x,NULL)[[1]]
    match(ss(x), ss(alpha)) - 1:1
}

id2ctxt <- function(id, m = nchar(alpha), alpha = NULL) {
    ## Purpose: Compute context from "ID" as returned by predict.vlmc

    if((m <- as.integer(m)) < 2)
        stop("alphabet length `m' must be >= 2")
    ## Improve (but then, use C anyway!):
    r <- vector("list", n <- length(id <- as.integer(id)))
    i.ok <- !is.na(id)
    r[!i.ok] <- NA
    lev <- floor(log(id, m))

    for(i in 1:n) if(i.ok[i]) {
        ii <- id[i]
        rr <- integer(lev[i])
        for(ll in lev[i]:1) {
            rr[ll] <- ii %% m
            ii <- ii %/% m
        }
        r[[i]] <- rr
    }
    if(is.null(alpha) || (is.logical(alpha) && !alpha))
        r # list of integer vectors
    else if(is.logical(alpha) && alpha)
        ## return string, using "01.." alphabet
        sapply(r, function(i)paste(i, collapse=""))
    else if(is.character(alpha)) { ## using  `alpha' alphabet
        if(length(alpha) > 1) ## return vector of characters
            sapply(r, function(i) alpha[1:1 + i])
        else ## return string
            sapply(r, function(i) int2char(i,alpha))
    }
    else {
        warning("invalid `alpha'; using alpha = NULL")
        r
    }
}
## })# local
