\name{logLik}
\alias{logLik.vlmc}
\alias{entropy}
\alias{entropy2}
\title{Log Likelihood of and between VLMC objects}
\description{
  Compute the log-likelihood or ``entropy'' of a fitted
  \code{\link{vlmc}} object.  This is a method for the
  generic \code{\link{logLik}}.
}
\usage{
entropy(object)
\method{logLik}{vlmc}(object, \dots)
entropy2(ivlmc1, ivlmc2, alpha.len = ivlmc1[1])
}
\arguments{
  \item{object}{typically the result of \code{\link{vlmc}(..)}.}
%
  \item{ivlmc1,ivlmc2}{two \code{vlmc} (sub) trees, see \code{\link{vlmc}}.}
  \item{alpha.len}{positive integer specifying the alphabet length.}
  \item{\dots}{(potentially more arguments; required by generic)}
}
\details{
  The \code{logLik.vlmc()} method computes the log likelihood for a fitted
  \code{\link{vlmc}} object.  \code{entropy} is an alias for
  \code{logLik} for reasons of back compatibility.

  \code{entropy2} is less clear ... ... [[[ FIXME ]]] ... ...
}
\value{
  a negative number, in some contexts typically further divided by
  \code{log(x$alpha.len)}.

  Note that the \code{logLik} method is used by the default method of
  the \code{\link{AIC}} generic function (from R version 1.4.x), and
  hence provides \code{AIC(object)} for vlmc objects.  Also, since vlmc
  version 1.3-13, \code{\link{BIC}()} works as well.
}
\author{Martin Maechler}
\seealso{\code{\link{deviance.vlmc}},
  \code{\link{vlmc}}, \code{\link{draw.vlmc}}.}
\examples{
dd <- cumsum(rpois(999, 1.5)) \%\% 10
(vd <- vlmc(dd))
logLik(vd)

## AIC model selection:
f1 <- c(1,0,0,0)  # as in example(vlmc)
f2 <- rep(1:0,2)
(dt1 <- c(f1,f1,f2,f1,f2,f2,f1))
AIC(print(vlmc(dt1)))
AIC(print(vlmc(dt1, cutoff = 2.6)))
AIC(print(vlmc(dt1, cutoff = 0.4)))# these two differ ``not really''
AIC(print(vlmc(dt1, cutoff = 0.1)))

## Show how to compute it from the fitted conditional probabilities :
logLikR <- function(x) {
    dn <- dimnames(pr <- predict(x))
    sum(log(pr[cbind(2:nrow(pr), match(dn[[1]][-1], dn[[2]]))]))
}

all.equal(  logLikR(vd),
          c(logLik (vd)), tol=1e-10) # TRUE, they do the same

## Compare different ones:  [cheap example]:
example(draw)
for(n in ls())
  if(is.vlmc(get(n))) {
       vv <- get(n)
       cat(n,":",formatC(logLik(vv) / log(vv$alpha.len),
                         format= "f", wid=10),"\n")
  }
}
\keyword{ts}
\keyword{models}
