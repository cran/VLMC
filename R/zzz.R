.First.lib <- function(lib, pkg) {
    library.dynam("VLMC",pkg,lib)
    require(MASS)# only for fractions() and rational()
    require(mva)# for dendrogram class & methods
}
