###-- Allow two ways to store the alphabet!  --- just the beginning

## alphabet() : return  *vector* of  `alpha.len'  alphabet "characters"

alphabet <- function(x, ...) UseMethod("alphabet")
alphabet.vlmc <- function(x, ...) {
    if(!is.vlmc(x)) stop("`x' is not a valid `vlmc' object")
    if(length(list(...)))
	stop("Extra arguments ", deparse(substitute(...)), " are discarded.")
    k <- x$alpha.len
    na <- length(a <- x$alpha)
    if(na == 1)  {
        if(nchar(a) != k)
            stop("invalid `alpha' string, #{chars} != alpha.len")
        strsplit(a, NULL)[[1]]
    } else {
        if(na != k)
            stop("invalid `alpha' vector, length != alpha.len")
        a
    }
}

