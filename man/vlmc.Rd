% $Id: vlmc.Rd,v 1.10 2003/07/09 08:16:05 maechler Exp $
\name{vlmc}
\title{Fit a Variable Length Markov Chain (VLMC)}
\alias{vlmc}
\alias{print.vlmc}
\alias{is.vlmc}
\description{
  Fit a Variable Length Markov Chain (VLMC) to a discrete time series,
  in basically two steps:\cr
  First a large Markov Chain is generated containing (all if
  \code{threshold.gen = 1}) the context states of the time series.  In
  the second step, many states of the MC are collapsed by \emph{pruning}
  the corresponding context tree.
}
\usage{
vlmc(dts,
     cutoff.prune = qchisq(alpha.c, df=max(.1,alpha.len-1),lower.tail=FALSE)/2,
     alpha.c = 0.05,
     threshold.gen = 2,
     code1char = TRUE, y = TRUE, debug = FALSE, quiet = FALSE,
     dump = 0, ctl.dump = c(width.ct = 1+log10(n), nmax.set = -1) )

is.vlmc(x)
\method{print}{vlmc}(x, digits = max(3, getOption("digits") - 3), \dots)
}
\arguments{
  \item{dts}{a discrete ``time series''; can be a numeric, character or factor.}
  \item{cutoff.prune}{non-negative number; the cutoff used for pruning;
    defaults to half the \eqn{\alpha}-quantile of a chisq distribution,
    where \eqn{\alpha =} \code{alpha.c}, the following argument:}
  \item{alpha.c}{number in (0,1) used to specify \code{cutoff.prune} in
    the more intuitive \eqn{\chi^2} quantile scale; defaulting to 5\%.}
  \item{threshold.gen}{integer \code{>= 1} (usually left at 2).  When
    \emph{generating} the initial large tree, only generate nodes with
    \code{count >= threshold.gen}.}
  \item{code1char}{logical; if true (default), the data \code{dts} will
    be ..........FIXME...........}
  \item{y}{logical; if true (default), the data \code{dts} will be
    returned.  This allows to ensure that residuals
    (\code{\link{residuals.vlmc}}) and ``k-step ahead'' predictions can
    be computed from the result.}
  \item{debug}{logical; should debugging info be printed to stderr.}
  \item{quiet}{logical; if true, don't print some warnings.}
%%\item{check.memory}{logical; for finding memory leak -- really not official.}
  \item{dump}{integer in \code{0:2}.  If positive, the pruned tree is
    dumped to stderr; if 2, the initial \bold{un}pruned tree is dumped as well.}
  \item{ctl.dump}{integer of length 2, say \code{ctl[1:2]} controlling
    the above dump when \code{dump > 0}.  \code{ctl[1]} is the width
    (number of characters) for the ``counts'', \code{ctl[2]} the maximal
    number of set elements that are printed per node; when the latter is
    not positive (by default), currently \code{max(6, 15 - log10(n))} is used.}
%
  \item{x}{a fitted \code{"vlmc"} object.}
  \item{digits}{integer giving the number of significant digits for
    printing numbers.}
  \item{\dots}{potentially further arguments [Generic].}
}
\value{
  A \code{"vlmc"} object, basically a list with components
  \item{n}{length of data series when fit.}
  \item{threshold.gen, cutoff.prune}{the arguments (or their defaults).}
  \item{alpha.len}{the alphabet size.}
  \item{alpha}{the alphabet used, as one string.}
  \item{size}{a named integer vector of length (>=) 4, giving
    characteristic sizes of the fitted VLMC.  Its named components are
    \describe{
      \item{"ord.MC"}{the (maximal) order of the Markov chain,}
      \item{"context"}{the ``context tree size'', i.e., the number of
	leaves plus number of ``hidden nodes'',}
      %---> reference to the Annals paper !,
      \item{"nr.leaves"}{is the number of leaves, and}
      \item{"total"}{the number of integers needed to encode the VLMC
	tree, i.e., \code{length(vlmc.vec)} (see below).}
    }
  }
  \item{vlmc.vec}{integer vector, containing (an encoding of) the fitted
    VLMC tree.}
  \item{y}{if \code{y = TRUE}, the data \code{dts}, as
    \code{\link{character}}, using the letters from \code{alpha}.}
  \item{call}{the \code{\link{call}} \code{vlmc(..)} used.}
}
\note{
  Set \code{cutoff = 0, thresh = 1} for getting a ``perfect fit'',
  i.e. a VLMC which perfectly re-predicts the data (apart from the first
  observation).  Note that even with \code{cutoff = 0} some pruning may
  happen, for all (terminal) nodes with \eqn{\delta}{delta}=0.
}
\references{
  Buhlmann P. and Wyner A. (1998)
  Variable Length Markov Chains.
  \emph{Annals of Statistics} \bold{27}, 480--513.

  Mächler M. and Bühlmann P. (2003)
  Variable Length Markov Chains: Methodology, Computing and Software.
  accepted for publication in \emph{J. Computational and Graphical Statistics}.

  Mächler M. (2003)
  VLMC --- Implementation and \R interface; working paper.
  %%Journal of Statistical Software, \emph{not yet submitted}.
}
\author{Martin Maechler}
\seealso{\code{\link{draw.vlmc}},
  \code{\link{entropy}}, \code{\link{simulate.vlmc}} for ``VLMC bootstrapping''.
}
\examples{
%--------------- don't change this example too quickly; used by many others!----
f1 <- c(1,0,0,0)
f2 <- rep(1:0,2)
(dt1 <- c(f1,f1,f2,f1,f2,f2,f1))

(vlmc.dt1  <- vlmc(dt1))
 vlmc(dt1, dump = 1,
      ctl.dump = c(wid = 3, nmax = 20), debug = TRUE)
(vlmc.dt1c01 <- vlmc(dts = dt1, cutoff.prune = .1, dump=1))

data(presidents)
dpres <- cut(presidents, c(0,45,70, 100)) # three values + NA
table(dpres <- factor(dpres, exclude = NULL)) # NA as 4th level
vlmc.pres <- vlmc(dpres, debug = TRUE)
vlmc.pres

## alphabet & and its length:
vlmc.pres$alpha
stopifnot(
  length(print(strsplit(vlmc.pres$alpha,NULL)[[1]])) == vlmc.pres$ alpha.len
)
}
\keyword{ts}
\keyword{models}
