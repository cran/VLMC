% $Id: predict.vlmc.Rd,v 1.9 2002/11/25 17:29:25 maechler Exp $
\name{predict.vlmc}
\title{Prediction of VLMC for (new) Series}
\description{
  Compute predictions on a fitted VLMC object
  for each (but the first) element of another discrete time series.
  Computes by default a matrix of prediction probabilities.  The argument
  \code{type} allows other predictions such as the most probable
  \code{"class"} or \code{"response"}, the context length (tree
  \code{"depth"}), or an \code{"ID"} of the corresponding context.
}
\alias{print.predict.vlmc}
\alias{predict.vlmc}
\alias{fitted.vlmc}
\usage{
\method{predict}{vlmc}(object, newdata,
         type = c("probs", "class","response", "id.node", "depth", "ALL"),
         se.fit = FALSE,%% dispersion = NULL, terms=NULL,
         allow.subset = TRUE, check.alphabet=TRUE,
         \dots)
\method{fitted}{vlmc}(object, \dots)
}
\arguments{
  \item{object}{typically the result of \code{\link{vlmc}(..)}.}
  \item{newdata}{a discrete ``time series'', a numeric, character or
    factor, as the \code{dts} argument of \code{\link{vlmc}(.)}.}

  \item{type}{character indicating the type of prediction required,
    options given in the \emph{Usage} secion above, see also the
    \emph{Value} section below.  The default \code{"probs"}
    returns a matrix of prediction probabilties, whereas \code{"class"}
    or \code{"response"} give the corresponding most
    probable class.  The value of this argument can be abbreviated.
  }
  \item{se.fit}{a switch indicating if standard errors are required.
    \cr --- NOT YET supported --- .}
%   \item{dispersion}{the dispersion of the GLM fit to be assumed in
%     computing the standard errors.  If omitted, that returned by
%     \code{summary} applied to the object is used.}
%   \item{terms}{with \code{type="terms"} by default all terms are returned.
%     A vector of strings specifies which terms are to be returned}

  \item{allow.subset}{logical; if \code{TRUE}, \code{newdata} may not
    have all different ``alphabet letters'' used in \code{x}.}
  \item{check.alphabet}{logical; if \code{TRUE}, consistency of
    \code{newdata}'s alphabet with those of \code{x} is checked.}
  \item{\dots}{(potentially further arguments) required by generic.}
}
\note{
  The \code{predict} method and its possible arguments are still in active
  development, and we are considering to return the marginal
  probabilities instead of \code{NA} for the first value(s).
}
\value{
  Depending on the \code{type} argument,
  \item{"probs"}{an \eqn{n \times m}{n * m} matrix \code{pm} of (prediction)
    probabilities, i.e., all the rows of \code{pm} sum to 1.

    \code{pm[i,k]} is
%%-- TODO : first row, instead of NA, use marginals  Pr[ Y[i] = k ] !!
    \eqn{\hat P[Y_i = k | Y_{i-1},\dots]}{Pr(Y[i]=k | Y[i-1,...])} (and
    is therefore \code{\link{NA}} for \code{i=1}).
    The \code{\link{dimnames}} of \code{pm} are the values of
    \code{newdata[]} and the alphabet letters \code{k}.}
  \item{"class", "response"}{the corresponding most probable value of Y[];
    as \code{factor} for \code{"class"} and as integer in
    \code{0:(m-1)} for \code{type = "response"}. If there is more than
    one most probable value, the first one is chosen.}
  \item{"id.node"}{an (integer) ``ID'' of the current context (= node
    of the tree represented VLMC).}
  \item{"depth"}{the context length, i.e., the depth of the
    Markov chain, at the current observation (of \code{newdata}).}

  \item{"ALL"}{an object of class \code{"predict.vlmc"}, a list with the
    following components,
    \describe{
      \item{ID}{integer vector as for \code{type = "id.node"},}
      \item{probs}{prediction probability matrix, as above,}
      \item{flags}{integer vector, non-zero for particular states only,
	rather for debugging.}

      \item{ctxt}{character, \code{ctxt[i]} a string giving the
	context (backwards) for \code{newdata[i]}, using alphabet
	letters.}
      \item{fitted}{character with fitted values, i.e., the alphabet letter
	with the highest probability, using \code{\link{max.col}} where
	ties are broken at random.}
      \item{alpha, alpha.len}{the alphabet (single string) and its
	length.}
    }
    which has its own print method (\code{print.predict.vlmc}).}
}
\seealso{\code{\link{vlmc}} and \link{residuals.vlmc}.}
\examples{
f1 <- c(1,0,0,0)
f2 <- rep(1:0,2)
(dt2 <- rep(c(f1,f1,f2,f1,f2,f2,f1),2))

(vlmc.dt2c15  <- vlmc(dt2, cutoff = 1.5))
draw(vlmc.dt2c15)

## Fitted Values:
all.equal(predict(vlmc.dt2c15, dt2), predict(vlmc.dt2c15))
(pa2c15 <- predict(vlmc.dt2c15, type = "ALL"))

## Depth = context length  ([1] : NA) :
stopifnot(nchar(pa2c15 $ ctxt)[-1] ==
          predict(vlmc.dt2c15, type = "depth")[-1])

same <- (ff1 <- pa2c15 $ fitted) ==
        (ff2 <- int2alpha(predict(vlmc.dt2c15, type ="response"), alpha="01"))
which(!same) #-> some are different, since max.col() breaks ties at random!

ndt2 <- c(rep(0,6),f1,f1,f2)
predict(vlmc.dt2c15, ndt2, "ALL")

(newdt2 <- sample(dt2, 17))
pm <- predict(vlmc.dt2c15, newdt2, allow.subset = TRUE)
summary(apply(pm, 1, sum))# all 1

predict(vlmc.dt2c15, newdt2, type = "ALL")

data(bnrf1)
(vbnrf <- vlmc(bnrf1EB))
(pA <- predict(vbnrf, bnrf1EB[1:24], type = "ALL"))
 pc <- predict(vbnrf, bnrf1EB[1:24], type = "class")
 pr <- predict(vbnrf, bnrf1EB[1:24], type = "resp")
stopifnot(as.integer  (pc[-1])   == 1 + pr[-1],
          as.character(pc[-1]) == strsplit(vbnrf$alpha,NULL)[[1]][1 + pr[-1]])

##-- Example of a "perfect" fit -- just for illustration:
##			    the default, thresh = 2 doesn't fit perfectly(i=38)
(vlmc.dt2c0th1 <- vlmc(dt2, cutoff = 0, thresh = 1))

## "Fitted" = "Data" (but the first which can't be predicted):
stopifnot(dt2[-1] == predict(vlmc.dt2c0th1,type = "response")[-1])
}
\keyword{ts}
\keyword{models}
