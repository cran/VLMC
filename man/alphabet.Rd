\name{alphabet}
\alias{alphabet}
\alias{alphabet.vlmc}
\title{The Alphabet in Use}
\description{
  Return the alphabet in use, as a vector of \dQuote{characters}.
}
\usage{
alphabet(x, \dots)
\method{alphabet}{vlmc}(x, \dots)
}
\arguments{
  \item{x}{any \R object, currently only available for
    \code{\link{vlmc}} ones.}
  \item{\dots}{potential further arguments passed to and from methods.}
}
% \details{
%   ~~ If necessary, more details than the __description__  above ~~
% }
\value{
  a \code{\link{character}} vector, say \code{r}, with length equal to
  the alphabet size.  Currently, typically all \code{r[i]} are strings
  of just one character.
}
\seealso{\code{\link{alpha2int}} for conversion to and from integer
  codings.
}
\examples{
data(bnrf1)
vb <- vlmc(bnrf1EB, cutoff = 5)
alphabet(vb) # |--> "a" "c" "g" "t"
}
\keyword{character}
\keyword{utilities}
