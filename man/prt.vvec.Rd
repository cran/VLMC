\name{prt.vvec}
\alias{prt.vvec}
\title{Recursively Print the VLMC Result Vector}
\description{
  This is an auxiliary function which recursively displays (prints) the
  integer result vector of a \code{\link{vlmc}} fit.
}
\usage{
prt.vvec(v, nalph, pad=" ")
}
\arguments{
  \item{v}{typically \code{x $ vlmc.vec[ -1]} where \code{x} is the
    result of \code{\link{vlmc}(*)}.}
  \item{nalph}{alphabet size; typically \code{x $ vlmc.vec[1]}.}
  \item{pad}{character, to be used for padding \code{paste(*, collapse=pad)}.}
}
\seealso{\code{\link{summary.vlmc}} which uses \code{prt.vvec}.}
\examples{
  example(vlmc)
  str(vv <- vlmc.dt1$vlmc)
  prt.vvec(vv[-1], n = 2)
  prt.vvec(vv[-1], n = 2, pad = " | ")
}
\keyword{utilities}


