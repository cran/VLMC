\name{alpha2int}
\alias{alpha2int}
\alias{int2alpha}
\title{`Single Character' <--> Integer Conversion for Discrete Data}
\description{
  Simple conversion functions for discrete data (e.g., time series),
  between \code{0:k} integers and \emph{single} letter characters.
}
\usage{
alpha2int(x, alpha)
int2alpha(i, alpha)
}
\arguments{
  \item{x}{character vector of single letters.}
  \item{alpha}{the alphabet, as one character string.}
  \item{i}{integer vector of numbers in \code{0:k}.}
}
\value{
  \code{alpha2int(x,*)} returns an \code{\link{integer}} vector of the same
  length as \code{x}, consisting of values from \code{0:k} where
  \code{k + 1} is the length of the alphabet, \code{\link{nchar}(alpha)}.

  \code{int2alpha(i,*)} returns a vector of \emph{single letter}
  \code{\link{character}} of the same length as \code{i}.
}
\seealso{\code{\link{vlmc}}, and
  \code{\link{int2char}()} and its inverse, \code{\link{char2int}()},
  both working with multi-character strings instead of vectors of single
  characters.
}
\examples{
alphabet <- "abcdefghijk"
(ch <- sample(letters[1:10], 30, replace = TRUE))
(ic <- alpha2int(ch, alphabet))
stopifnot(int2alpha(ic, alphabet) == ch)
}
\keyword{utilities}
