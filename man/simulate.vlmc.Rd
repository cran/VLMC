\name{simulate.vlmc}
\alias{simulate.vlmc}
\title{Simulate a Discrete Time Series from fitted VLMC model}
\description{Simulate from fitted VLMC model -- basis of the VLMC bootstrap}
\usage{
simulate.vlmc(x, n, n.start = 64 * x$size["context"], integer.return=FALSE)
}
\arguments{
  \item{x}{typically the result of \code{\link{vlmc}(..)}.}
  \item{n}{non-negative integer, giving the length of the result.}
  \item{n.start}{the number of initial values to be
    discarded (because of initial effects).}
  \item{integer.return}{logical; if \code{TRUE}, the result will be an
    \code{\link{integer}} vector with values in \code{0:(k-1)};
    otherwise the resulting vector consists of letters from the alphabet
    \code{x$alpha}.}
}
\details{
  The \code{\link{.Random.seed}} is used and updated as with other random
  number generation routines such as \code{\link{rbinom}}.

  Note that if you want to simulate from a given start sequence
  \code{x0}, you'd use \code{\link{predict.vlmc}(x, x0, type= "response")}
  --- actually not quiet yet.
}
\value{
  A vector of length \code{n}.  Either \code{\link{integer}} or
  \code{\link{character}}, depending on the \code{integer.return}
  argument, see above.
}
\author{Martin Maechler}
\seealso{\code{\link{vlmc}}.}
\examples{
example(vlmc)

simulate.vlmc(vlmc.dt1, 100)
simulate.vlmc(vlmc.dt1c01, 100, int = TRUE)
# n.start = 0: 1st few observations will resemble the data
simulate.vlmc(vlmc.dt1c01, 20, n.start=0, int = TRUE)

}
\keyword{ts}
\keyword{models}
