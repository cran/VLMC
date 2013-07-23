% $Id: residuals.vlmc.Rd,v 1.11 2012/09/11 16:57:09 maechler Exp $
\name{residuals.vlmc}
\alias{residuals.vlmc}
\title{Compute Residuals of a Fitted VLMC Object}
\description{
  Compute residuals of a fitted \code{\link{vlmc}} object.

  This is yet a matter of research and may change in the future.
}
\usage{
\method{residuals}{vlmc}(object,
        type = c("classwise",
                 "deviance", "pearson", "working", "response", "partial"),
        y = object$y, \dots)
}
\arguments{
 \item{object}{typically the result of \code{\link{vlmc}(..)}.}
 \item{type}{The type of residuals to compute, defaults to
   \code{"classwise"} which returns an \eqn{n \times m}{n x m} matrix,
   see below.  The other types only make sense when the discrete
   values of \code{y} are ordered which always includes the binary case
   (\eqn{m=2}).
   \cr
   The \code{"deviance"} residuals \eqn{r} are defined similarly as for logistic
   regression, see below.
   \cr
   "pearson", "working" and "response" are currently
   identical and give the difference of the underlying integer code (of
   the discrete data).
   %%
   \bold{Note} that \code{"partial"} residuals are not yet defined!
 }
 \item{y}{discrete time series with respect to which the residuals are
   to be computed.}
 \item{\dots}{possibly further arguments (none at the moment).}
}
\value{
  If \code{type = "classwise"} (the default), a numeric matrix of dimension
  \eqn{n \times m}{n x m} of values \eqn{I_{i,j} - p_{i,j}}{I[i,j] -
    p[i,j]} where the indicator \eqn{I_{i,j}}{I[i,j]} is 1 iff
  \code{y[i] == a[j]} and \code{a} is the alphabet (or levels) of
  \code{y}, and \eqn{p_{i,j}}{p[i,j]} are the elements of the estimated (1-step
  ahead) predicted probabilities, \code{p <- predict(object)}.
  Hence, for each \eqn{i}, the only positive residual stands for the
  observed class.

  For all other \code{type}s, the result is
  a numeric vector of the length of the original time-series (with first
  element \code{NA}).\cr
  For \code{type = "deviance"},
  \eqn{r_i = \pm\sqrt{-2\log(P_i)}}{r[i] = +- sqrt(-2 log(P[i]))}
  where \eqn{P_i}{P[i]} is the predicted probability for the i-th
  observation which is the same as \eqn{p_{i,y_i}}{p[i,y[i]]} above (now
  assuming \eqn{y_i \in \{1,2,\dots,m}{y[i] in \{1,2,...,m\}}).
  The sum of the squared deviance residuals \emph{is} the deviance of
  the fitted model.
}
\author{Martin Maechler}
\seealso{\code{\link{vlmc}},\code{\link{deviance.vlmc}}, and
  \code{\link{RCplot}} for a novel residual plot.}
\examples{
example(vlmc)
rp <- residuals(vlmc.pres)
stopifnot(all(abs(apply(rp[-1,],1,sum)) < 1e-15))
matplot(seq(presidents), rp, ylab = "residuals", type="l")
## ``Tukey-Anscombe'' (the following is first stab at plot method):
matplot(fitted(vlmc.pres), rp, ylab = "residuals", xaxt = "n",
        type="b", pch=vlmc.pres$alpha)
axis(1, at = 0:(vlmc.pres$alpha.len-1),
     labels = strsplit(vlmc.pres$alpha,"")[[1]])


summary(rd <- residuals(vlmc.pres, type = "dev"))
rd[1:7]
## sum of squared dev.residuals === deviance :
all.equal(sum(rd[-1] ^ 2),
          deviance(vlmc.pres))
\dontshow{stopifnot(all.equal(sum(rd[-1] ^ 2),
                    deviance(vlmc.pres),tol=1e-12))
}
}
\keyword{ts}
\keyword{models}
