\name{vlmctree}
\alias{vlmctree}
\alias{.vvec2tree}
\alias{str.vtree}
\title{Compute the tree structure of a "vlmc" object}
\description{
  Compute the tree representation of a \code{"\link{vlmc}"} object as \R
  \code{\link{list}}.
}
\usage{
vlmctree(x)

\method{str}{vtree}(object, \dots)
.vvec2tree(vv, k, chk.lev)
}
\arguments{
  \item{x,object}{typically the result of \code{\link{vlmc}(..)}.}
  \item{vv}{integer vector encoding the fitted vlmc, typically
    \code{x$vlmc.vec[-1]}.}
  \item{k}{integer, the alphabet size.}
  \item{chk.lev}{integer internally used for consistency checking.}
  \item{\dots}{further arguments passed to or from methods.}
}
\details{
  \code{.vvec2tree} is the internal (recursive) function building up the
  tree.

  \code{str.vtree} is a method for the generic \code{\link{str}}
  function and typically for the output of \code{vlmctree()}. For each
  node, it gives the ``parenting level'' in braces and the counts.
}
\value{
  A \code{\link{list}} of \code{\link{class}} \code{"vtree"}
  representing the tree structure recursively.

  Each ``node'' of the tree is itself a list with
  components
  \item{level}{length-2 integer giving the level in \{0,1,\dots\},
    counted from the root (which is \code{0}) and the parenting level,
    i.e the longest branch.}
  \item{count}{integer vector of length \code{k} where \code{k} is the
    number of ``letters'' in the alphabet.}
  \item{total}{equals to \code{sum(* $ count)}.}
  \item{child}{a list (of length \code{k}) of child nodes or
    \code{\link{NULL}} (i.e. not there).}
}
\author{Martin Maechler}
\seealso{\code{\link{vlmc}}.}
\examples{
data(presidents)
dpres <- cut(presidents, c(0,45,70, 100)) # three values + NA
table(dpres <- factor(dpres, exclude = NULL)) # NA as 4th level

(vlmc.prc1 <- vlmc(dpres, cut = 1, debug = TRUE))
str(vv.prc1 <- vlmctree(vlmc.prc1))
}
\keyword{ts}
\keyword{models}
