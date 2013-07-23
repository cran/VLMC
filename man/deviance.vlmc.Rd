\name{deviance.vlmc}
\alias{deviance.vlmc}
\title{Compute the Deviance of a Fitted VLMC Object}
\description{
  Compute the Deviance, i.e., - 2 log[likelihood(*)] of a fitted VLMC
  object.  The log-likelihood is also known as ``entropy''.
}
\usage{
\S3method{deviance}{vlmc}(object, ...)
}
\arguments{
 \item{object}{typically the result of \code{\link{vlmc}(..)}.}
 \item{\dots}{possibly further arguments (none at the moment).}
}
\value{
  A number, the deviance, i.e., \eqn{- 2 log.likelihood(*)}.
  where the  log.likelihood is really what we currently have
  as \code{\link{entropy}()}.

%% FIXME : need more here ???

}
\author{Martin Maechler}
\seealso{\code{\link{entropy}}, \code{\link{vlmc}},\code{\link{residuals.vlmc}}}
\examples{
example(vlmc)
deviance(vlmc.pres)

devianceR <- function(object)
{
    dn <- dimnames(pr <- predict(object))
    -2 * sum(log(pr[cbind(2:nrow(pr), match(dn[[1]][-1], dn[[2]]))]))
}
all.equal(deviance(vlmc.pres), devianceR(vlmc.pres), tol = 1e-14)
}
\keyword{ts}
\keyword{models}
