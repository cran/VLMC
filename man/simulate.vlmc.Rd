\name{simulate.vlmc}
\alias{simulate.vlmc}
\title{Simulate a Discrete Time Series from fitted VLMC model}
\description{Simulate from fitted VLMC model -- basis of the VLMC bootstrap}
\usage{
\method{simulate}{vlmc}(object, nsim = 1, seed = NULL, n,
         n.start = 64 * object$size[["context"]],
         integer.return = FALSE, keep.RSeed = TRUE, \dots)
}
\arguments{
  \item{object}{typically the result of \code{\link{vlmc}(..)}.}
  \item{nsim, n}{non-negative integer, giving the length of the result.
    Note that \code{n} is deprecated and just there for back compatibility.}
  \item{seed}{random seed initializer; see \code{\link[stats]{simulate}}.}
  \item{n.start}{the number of initial values to be
    discarded (because of initial effects).}
  \item{integer.return}{logical; if \code{TRUE}, the result will be an
    \code{\link{integer}} vector with values in \code{0:(k-1)};
    otherwise the resulting vector consists of letters from the alphabet
    \code{x$alpha}.}
  \item{keep.RSeed}{logical indicating if the seed should be stored with
    the result (as \sQuote{required} by the generic
    \code{\link{simulate}}).  Only set this \code{FALSE} with good
    reasons (back compatibility).}
  \item{\dots}{(potentially further arguments for other \code{simulate}
    methods.}
}
\details{
  The \code{\link{.Random.seed}} is used and updated as with other random
  number generation routines such as \code{\link{rbinom}}.

  Note that if you want to simulate from a given start sequence
  \code{x0}, you'd use \code{\link{predict.vlmc}(x, x0, type= "response")}
  --- actually not quite yet.
}
\value{
  A \code{"simulate.vlmc"} object, basically a vector of length
  \code{nsim}.  Either \code{\link{integer}} or \code{\link{character}},
  depending on the \code{integer.return} argument, see above.  Further,
  if \code{keep.RSeed} was true (as by default), a \code{"seed"} attribute
  with the random seed at the start of the simulation, for reproducibility.
}
\author{Martin Maechler}
\seealso{\code{\link{vlmc}} and \code{\link{predict.vlmc}}.}
\examples{
example(vlmc)

simulate(vlmc.dt1, 100)
simulate(vlmc.dt1c01, 100, int = TRUE)
# n.start = 0: 1st few observations will resemble the data
simulate(vlmc.dt1c01, 20, n.start=0, int = TRUE)

\dontshow{## technical consistency checks
ww <- tools::assertWarning(sv <- simulate.vlmc(vlmc.dt1, 100))# deprecation
s2 <- simulate(vlmc.dt1c01, 16, n.start=100, int = TRUE, keep.RSeed=FALSE)
.Random.seed <- attr(sv,"seed")
s3 <- simulate(vlmc.dt1, n=100)
stopifnot(length(sv) == 100, length(s2) == 16, identical(sv, s3),
	  grepl("deprecated", ww[[1]][["message"]]),
	  !is.na(match(names(attributes(s2)), c("name","class"))))
}%dont
}
\keyword{ts}
\keyword{models}
