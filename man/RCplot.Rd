\name{RCplot}
\encoding{latin1}
\alias{RCplot}
\title{Residuals vs Context plot}
\description{
  Plots the residuals of a fitted VLMC model against the contexts, i.e.,
  produces a boxplot of residuals for all contexts used in the model fit.

  This has proven to be useful function, and the many optional arguments
  allow quite a bit of customization.  However, the current
  implementation is somewhat experimental and the defaults have been
  chosen from only a few examples.
}
\usage{
RCplot(x, r2 = residuals(x, "deviance")^2,
       alphabet = x$alpha, lab.horiz = k <= 20,
       do.call = TRUE,
       cex.axis = if (k <= 20) 1 else if (k <= 40) 0.8 else 0.6,
       y.fact = if (.Device == "postscript") 1.2 else 0.75,
       col = "gray70", xlab = "Context", main = NULL,
       med.pars = list(col = "red", pch = 12, cex = 1.25 * cex.axis),
       ylim = range(0, r2, finite = TRUE),
       \dots)
}
\arguments{
  \item{x}{an \R object of class \code{vlmc}.}
  \item{r2}{numeric vector, by default of squared deviance residuals of
    \code{x}, but conceptually any (typically non-negative) vector of
    the appropriate length.}
  \item{alphabet}{the alphabet to use for labeling the contexts,
    via \code{\link{id2ctxt}}.}
  \item{lab.horiz}{logical indicating if the context labels should be
    written \bold{horiz}ontally or vertically.}
  \item{do.call}{logical indicating if the \code{\link{vlmc}} call
    should be put as subtitle.}
  \item{cex.axis}{the character expansion for axis labeling, see also
    \code{\link{par}}.  The default is only approximately good.}
  \item{y.fact}{numeric factor for expanding the space to use for the
    context labels (when \code{lab.horiz} is false).}
  \item{col}{color used for filling the boxes.}
  \item{xlab}{x axis label (with default).}
  \item{main}{main title to be used, \code{NULL} entailing a sensible default.}
  \item{med.pars}{graphical parameters to be used for coding of medians
    that are almost 0.}
  \item{ylim}{y range limits for plotting.}
  \item{\dots}{further arguments to be passed to \code{plot()}.}
}
\value{
  \emph{Invisibly}, a list with components
  \item{k}{the number of contexts (and hence box plots) used.}
  \item{fID}{a factor (as used in the interncal call to
    \code{\link{plot.factor}}).}
  \item{rp}{a list as resulting from the above call to \code{plot.factor()}.}
}
\references{
  Mächler M. and Bühlmann P. (2004)
  Variable Length Markov Chains: Methodology, Computing, and Software.
  \emph{J. Computational and Graphical Statistics} \bold{2}, 435--455.
}
\author{Martin Maechler}
\seealso{\code{\link{summary.vlmc}} for other properties of a VLMC model.}
\examples{
example(vlmc)
RCplot(vlmc.pres)
RCplot(vlmc.dt1c01)## << almost perfect fit (0 resid.)
}
\keyword{hplot}
\keyword{utilities}
