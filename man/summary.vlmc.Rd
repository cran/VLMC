\name{summary.vlmc}
\title{Summary of Fitted Variable Length Markov Chain (VLMC)}
\alias{summary.vlmc}
\alias{print.summary.vlmc}
\description{
  Compute (and print) a summary of a \code{vlmc} object which is
  typically the result of \code{\link{vlmc}(..)}.
}
\usage{
\method{summary}{vlmc}(object, \dots)
\method{print}{summary.vlmc}(x, digits = getOption("digits"),
         vvec.printing = FALSE, \dots)
}
\arguments{
  \item{object}{an \R object of class \code{vlmc}.}
  \item{x}{an \R object of class \code{summary.vlmc}.}
  \item{digits}{integer giving the number of significant digits for
    printing numbers.}
  \item{vvec.printing}{logical indicating if the \code{vvec} component
    should be printed recursively via \code{\link{prt.vvec}()}.}
  \item{\dots}{potentially further arguments [Generic].}
}
\value{
  \code{summary.vlmc()} returns an object of class \code{"summary.vlmc"}
  for which there's a print method. It is basically a list containing
  all of \code{object}, plus additionally
  \item{confusion.table}{the symmetric contingency table of data vs fitted.}
  \item{depth.stats}{statistics of Markov chain depth along the data;
    currently just \code{summary(predict(object, type="depth"))}.}
  \item{R2}{the \eqn{R^2} statistic, i.e. the percentage (in [0,1]) of
    correctly predicted data.}
}
\seealso{\code{\link{vlmc}}, \code{\link{draw.vlmc}}.}
\examples{
data(bnrf1)
vb <- vlmc(bnrf1EB)
svb <- summary(vb)
svb
\dontshow{% needs options(expression = <larger>) :
try(## since it currently fails (".. nested too deeply") -- FIXME -- !
  print(svb, vvec.print = TRUE)
)
}
}
\keyword{ts}
\keyword{models}
