\name{id2ctxt}
\alias{id2ctxt}
\title{VLMC Context ID Conversion}
\description{
  Utility for converting a \code{\link{vlmc}} state ID to the
  corresponding context.  Of rare interest to the average user.
}
\usage{
id2ctxt(id, m=nchar(alpha), alpha=NULL)
}
\arguments{
  \item{id}{integer, a context ID such as optionally returned by
    \code{\link{predict.vlmc}}.}
  \item{m}{integer, the alphabet length.  Defaults to
    \code{\link{nchar}(alpha)}, the alphabet size if that is given.}
  \item{alpha}{alphabet string}
}
\value{
  a list (if \code{alpha} is not specified) or character vector of the
  same length as \code{id}, giving the 
  context (as integer vector or single string) of the corresponding id
}
\seealso{\code{\link{predict.vlmc}(*, type = "ID")}.}
\examples{
    id2ctxt(c(2,3,5,9), alpha = "Ab")
str(id2ctxt(c(2,3,5,9), 2))
}
\keyword{utilities}
