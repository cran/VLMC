\name{int2char}
\alias{int2char}
\alias{char2int}
\title{Character - Integer Conversion}
\description{
  Simple conversion utilities for character to integer conversion and
  vice versa.
}
\usage{
int2char(i, alpha)
char2int(x, alpha)
}
\arguments{
  \item{i}{integer vectors, typically in \code{0:m} when \code{alpha}
    has \eqn{m + 1} letters.}
  \item{alpha}{character string with several letters, representing the
    alphabet.}
  \item{x}{character string, typically with letters from \code{alpha}.}
}
\value{
  \code{int2char()} gives a string (length 1 character) with as many
  characters as \code{length(i)}, by 0-indexing into the alphabet
  \code{alpha}.

  \code{char2int()} gives an integer vector of length \code{nchar(x)}
  of integer codes according to \code{alpha} (starting at 0 !).

}
\seealso{\code{\link{int2alpha}()} (which is used by \code{int2char})
  and its inverse, \code{\link{int2alpha}()}, both working with vectors
  of \emph{single} characters instead of multi-character strings.
}
\examples{
char2int("vlmc", paste(letters, collapse=""))

int2char(c(0:3, 3:1), "abcd")
int2char(c(1:0,3,3), "abc") # to eat ;-)
}
\keyword{character}
\keyword{utilities}
