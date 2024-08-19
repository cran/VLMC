\name{bnrf1}
\title{BNRF1 Gene DNA sequences: Epstein-Barr and Herpes}
\description{
  Two gene DNA data ``discrete time series'',
  \describe{
    \item{\code{bnrf1EB}}{the BNRF1 gene from the Epstein-Barr virus,}
    \item{\code{bnrf1HV}}{the BNRF1 gene from the herpes virus.}
  }
}
\alias{bnrf1EB}
\alias{bnrf1HV}
\usage{data(bnrf1)}
\format{
  The EB sequence is of \code{\link{length}} 3954, whereas the HV has
  3741 nucleotides.
  Both are \R \code{\link{factor}}s with the four levels
  \code{c("a","c","g","t")}.
}
\source{
  See the references; data used to be at
  \verb{https://anson.ucdavis.edu/~shumway/tsa.html}, and are now available
  in CRAN package \CRANpkg{astsa}, e.g., \code{\link[astsa]{bnrf1ebv}}.
}
\references{
  Shumway, R. and Stoffer, D. (2000)
  \emph{Time Series Analysis and its Applications}.
  Springer Texts in Statistics.
}
\author{Martin Maechler (original packaging for \R).}
\examples{
data(bnrf1)
bnrf1EB[1:500]
table(bnrf1EB)
table(bnrf1HV)
n <- length(bnrf1HV)
table(t = bnrf1HV[-1], "t-1" = bnrf1HV[-n])

plot(as.integer(bnrf1EB[1:500]), type = "b")
\dontshow{
 ftable(table( t = bnrf1HV[-(1:2)],
              "t-1" = bnrf1HV[-c(1,n)],
              "t-2" = bnrf1HV[-c(n-1,n)]))
 lag.plot(jitter(as.ts(bnrf1HV)),lag = 4, pch = ".")
}

## Simplistic gene matching:
percent.eq <- sapply(0:200,
           function(i) 100 * sum(bnrf1EB[(1+i):(n+i)] ==  bnrf1HV))/n
plot.ts(percent.eq)
}
\keyword{datasets}
