% $Id: draw.vlmc.Rd,v 1.7 2002/11/25 16:15:06 maechler Exp maechler $
\name{draw.vlmc}
\alias{draw.vlmc}
\alias{draw}
\title{Draw a "VLMC" Object (in ASCII) as tree.}
\description{
  Draws a \code{vlmc} object, typically the result of
  \code{\link{vlmc}(.)}, to the \R console,
  using one line per node.
}
\usage{
draw(x, \dots)
draw.vlmc(x, kind=3, flag = TRUE, show.hidden = 1,
          cumulative = TRUE, delta = cumulative, debug = FALSE, \dots)
}
\arguments{
  \item{x}{typically the result of \code{\link{vlmc}(..)}.}
  \item{kind}{integer code for the ``kind of drawing'', in \{0,1,2,3\}.}
  \item{flag}{logical; ..}
  \item{show.hidden}{integer code; if not \code{0}, give some
    indications about hidden (final) nodes .....}
  \item{cumulative}{logical indicating if the cumulative counts should
    be shown for nonterminal nodes; the `delta's can only be computed
    from the cumulative counts, i.e., \code{cumulative = FALSE} should
    be used only by the knowing one.}
  \item{delta}{logical indicating if `delta',
    i.e. \eqn{\delta}{delta}\eqn{(n, p(n))} should be computed and printed for
    each (non-root) node \eqn{n} with parent \eqn{p(n)}.  Note that this
  does not really make sense when \code{cumulative = FALSE}.}
  \item{debug}{logical; if \code{TRUE}, some extraneous progress
    information is printed to the \R console.}
  \item{\dots}{(potentially more arguments)}
}
\details{
 .............

%% FIXME -- DO THIS ---

 .............

 Note that the counts internally are stored ``non-cumulatively'',
 i.e. as \emph{difference} counts which is useful for likelihood (ratio)
 computations.  In the internal C code, the \emph{difference} counts are
 originally computed by the \code{comp_difference()} function after tree
 generation.  \code{draw(*, cumulative = TRUE)} internally calls the C
 function \code{cumulate()} for the cumulative sums.
}
\value{
  nothing is returned.}
\author{Martin Maechler}
\seealso{\code{\link{vlmc}}.}
\examples{
  example(vlmc)
  draw(vlmc.dt1c01)
  draw(vlmc.dt1c01, flag = FALSE)
  draw(vlmc.dt1c01, kind = 1)
  draw(vlmc.dt1)
  draw(vlmc.dt1, show = 3)
  draw(vlmc.dt1, cumulative = FALSE)
}
\keyword{ts}
\keyword{models}
