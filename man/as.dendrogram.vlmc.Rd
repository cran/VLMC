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
% \details{
%   ~~ If necessary, more details than the __description__  above ~~
% }
\value{
  An object of class \code{\link{dendrogram}}, i.e. a nested list
  described on that page.
 %% FIXME add ??
}
\seealso{\code{\link[mva]{as.dendrogram}}, \code{\link[mva]{plot.dendrogram}}.}

\examples{
data(presidents)
dpr <- factor(cut(presidents, c(0,45,70,100)), exclude=NULL)# NA = 4th level
(vlmc.pres <- vlmc(dpr))
draw(vlmc.pres)
(dv.dpr <- as.dendrogram(vlmc.pres))
if(FALSE) {%% FIXME!!
 str(dv.dpr) ##==> `INFINITE' LOOP
 plot(dv.dpr)##==> Error
}
}
\keyword{graphs}% <<< INVALID for now!
\keyword{iplot}% (since that's one main use..)
