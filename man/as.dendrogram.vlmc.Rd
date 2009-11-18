\name{as.dendrogram.vlmc}
\alias{as.dendrogram.vlmc}
\title{Dendrogram Construction from VLMCs}
\description{
  This is a method for the \code{as.dendrogram} generic function
}
\usage{
as.dendrogram.vlmc(object, \dots)
}
\arguments{
  \item{object}{a \code{\link{vlmc}} object.}
  \item{\dots}{further arguments passed to and from methods.}
}
\value{
  An object of class \code{\link{dendrogram}}, i.e. a nested list
  described on that page.
 %% FIXME add ??
}
\seealso{\code{\link{as.dendrogram}}, \code{\link{plot.dendrogram}}.}

\examples{
data(presidents)
dpr <- factor(cut(presidents, c(0,45,70,100)), exclude=NULL)# NA = 4th level
(vlmc.pres <- vlmc(dpr))
draw(vlmc.pres)
(dv.dpr <- as.dendrogram(vlmc.pres))
str(dv.dpr)
str(unclass(dv.dpr))

%% type = "tr" and these two `pch' should be *default*
plot(dv.dpr, type ="tr", nodePar = list(pch=c(1,16), cex = 1.5))

## Artificial example
f1 <- c(1,0,0,0) ; f2 <- rep(1:0, 2)
(dt1 <- c(f1,f1,f2,f1,f2,f2,f1))
(vlmc.dt1c01 <- vlmc(dts = dt1, cutoff.prune = 0.1))
(dvlmc <- as.dendrogram(vlmc.dt1c01))
%% ALSO: Should allow (and use by default!) a "hang = +1"
str(dvlmc)
%%% FIXME !!! ---
## not so useful:
plot(dvlmc, nodePar= list(pch=c(1,16)))
## complete disaster:
plot(dvlmc, type ="tr", nodePar= list(pch=c(1,16)))

## but this is not (yet) so much better (want the same angles to left
## and right!!
plot(dvlmc, type ="tr", nodePar = list(pch=c(1,16)), center=TRUE,
     main = format(vlmc.dt1c01$call))
mtext(paste("dt1 =", gsub(" ","",deparse(dt1,width=100))))
}
\keyword{graphs}% <<< INVALID for now!
\keyword{iplot}% (since that's one main use..)
