####--- as.dendrogram() method - in order to plot the context - tree

## Generic and hclust method are in
##  /u/maechler/R/D/r-devel/R/src/library/mva/R/dendrogram.R

##-   The dendrogram is directly represented as a nested list, where each list
##-   component corresponds to a branch of the tree. Hence, the first branch
##-   of tree \code{z} is \code{z[[1]]}, the second branch of the
##-   corresponding subtree is \code{z[[1]][[2]]} etc.. Each node of the tree
##-   carries some information needed for efficient plotting or cutting as
##-   attributes:
##-   \describe{
##-     \item{\code{members}}{number of leaves in the branch}
##-     \item{\code{height}}{Height at which the node is plotted}
##-     \item{\code{midpoint}}{Horizontal distance of the node from the left
##-       border of the branch}
##-     \item{\code{text}}{Text label of the node}
##-     \item{\code{edgetext}}{Text label for the edge leading to the node}
##-   }
##-   Terminal nodes (leaves of the tree) can have arbitrary value but must
##-   not be a list.

if(FALSE) {
    require(mva)

    as.dendrogram.vlmc <- function(object, ...)
    {
        ## Purpose:
        ## -----------------------------------------------------------------
        ## Arguments:
        ## -----------------------------------------------------------------
        ## Author: Martin Maechler, Date: 29 Sep 2001, 18:20
    }

} ## not yet
