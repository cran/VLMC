simulate.vlmc <-
    function(x, n, n.start = 64 * x$size["context"], integer.return = FALSE)
{
    ## Author: Martin Maechler, Date: 10 Apr 2000
    if(!is.vlmc(x))
	stop("first argument must be a \"vlmc\" object; see ?vlmc")
    ivlmc <- x $ vlmc

    if(0 > (n <- as.integer(n)))
        stop("require output-length n must be >= 0")
    n <- as.integer(n + n.start)
    m <- as.integer(x $ alpha.len)

    iy <- .C("sim_vlmc",
             vlmc.vec	= as.integer(ivlmc),
             size	= length(ivlmc),
             m          = m,
             data.len	= n,
             y 		= integer(n),
             DUP	= FALSE,
             PACKAGE	= "VLMC")$y[-(1:n.start)]

    if(integer.return) iy else strsplit(x$alpha, NULL)[[1]][1 + iy]
}





