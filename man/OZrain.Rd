\name{OZrain}
\alias{OZrain}
\title{Daily Rainfall in Melbourne, Australia, 1981-1990}
\description{Amount of daily rainfall in Melbourne, Australia,
  1981-1990, measured in millimeters.  The amounts are integers with
  many zeros and three days of more than 500mm rain.
}
\usage{data(OZrain)}
\format{
  A time-series of length 3653 with the amount of daily rainfall in mm.
  Because of the two leap years 1984 and '88, we have constructed it
  with \code{\link{ts}(*, start=1981, frequency=365.25,
    end = 1981+ (3653 - 1)/365.25)}.
}
\source{
  \file{rainfall.dat} in Rob J. Hyndman's \emph{Time Series Data Library},
  \url{http://www-personal.buseco.monash.edu.au/~hyndman/TSDL/}

  originally, Australian Bureau of Meteorology, \url{http://www.abs.gov.au}.
}
\note{
  There must be one extra observation since for the ten years with two
  leap years, there are only 3652 days.
  In 61 out of 100 days, there's no rain.
}
\examples{
data(OZrain)
(n <- length(OZrain)) ## should be 1 more than
ISOdate(1990,12,31) - ISOdate(1981, 1,1)## but it's 2 ..

has.rain <- OZrain > 0

summary(OZrain[has.rain])# Median = 18,  Q3 = 50
table(rain01 <- as.integer(has.rain))
table(rain4c <- cut(OZrain, c(-.1, 0.5, 18.5, 50.1, 1000)))

\testonly{
  table(rain4c <- as.integer(rain4c) - 1:1)
  draw(v4 <- vlmc(rain4c))
  v4 # cutoff 3.907; MC = 9, context = 39
  vlmc(rain4c, cut = 0  )$size # MC = 25; context = 2355, #{leaves}= 1062
  vlmc(rain4c, cut = 0.1)$size # MC = 25; context = 2344
  vlmc(rain4c, cut = 0.3)$size # MC = 25; context = 1990, #{leaves}=  967
%% ../tests/iid-cutoff.R finds an "iid-correct cutoff" of ~ 6
  vlmc(rain4c, cut = 6.0)$size # MC =  7; context =   10, #{leaves}=    4
  lLv <- function(co) {
    l <- logLik(vlmc(rain4c, cut = co)); c(Ll = l, df = attr(l,"df"))
  }
  cuts4 <- c(0,0.1,0.3,0.5,0.7, seq(1,7, by = .25), 9, 12,13)
  ll4 <- sapply(cuts4, lLv)
  par(mfcol = c(2,2))
  plot(cuts4, AIC4 <- c(c(-2,2) \%*\% ll4), type = 'b')
  plot(cuts4, BIC4 <- c(c(-2,log(n)) \%*\% ll4), type = 'b')
  ii <- cuts4 > 2.
  plot(cuts4[ii], AIC4[ii], type = 'b')
  plot(cuts4[ii], BIC4[ii], type = 'b')
}% testonly

AIC(v1  <- vlmc(rain01))# cutoff = 1.92
AIC(v00 <- vlmc(rain01, cut = 1.4))
AIC(v0  <- vlmc(rain01, cut = 1.5))

\testonly{
  lLv <- function(co) {
    cat(co,"")
    l <- logLik(vlmc(rain01, cut = co))
    c(Ll = l, df = attr(l,"df"))
  }
  cc <- seq(1., 3, len = 401)
  system.time(vll <- sapply(cc, lLv))# 21 & 49 sec. (on P III 900 MHz)
  llv <- vll["Ll",] ; dfv <- vll["df",]
  par(mfrow=c(2,2))
  ## very interesting:  quite a few local minima!!
  plot  (cc, -2*llv + 2*dfv, type='l', main="AIC(vlmc(rain01, cutoff = cc))")
  plot  (cc, dfv, type='l', main="Complexity(vlmc(*, cutoff = cc))")
  plot  (cc, llv, type='l', main="Log.Likelihood(vlmc(*, cutoff = cc))")

  ## BIC is all falling:
  ##  par(new=T)
  plot  (cc, -2*llv + log(3653)*dfv, type='l', main="BIC(vlmc(*, cutoff = cc))")
}

hist(OZrain)
hist(OZrain, breaks = c(0,1,5,10,50,1000), xlim = c(0,100))

plot(OZrain, main = "Rainfall 1981-1990 in Melbourne")
## work around bug in plot.ts() for R <= 1.3.1 :
newer1.4 <- {v <- R.version; v$major > 1 || as.numeric(v$minor) >= 4.2}
if(newer1.4) {
  plot(OZrain, log="y", main = "Non-0 Rainfall [LOG scale]")
} else
  plot.ts(time(OZrain)[has.rain],
          OZrain[has.rain], log="y", main = "Non-0 Rainfall [LOG scale]")
lOZ <- lowess(log10(OZrain[has.rain]), f= .05)
lines(time(OZrain)[has.rain], 10^lOZ$y, col = 2, lwd = 2)
}
\keyword{datasets}
