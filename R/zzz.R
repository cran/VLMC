.First.lib <- function(lib, pkg) {
    library.dynam("VLMC",pkg,lib)
    require(MASS)# only for fractions() and rational()
    if(paste(R.version$major, R.version$minor, sep=".") < 1.9)
        require(mva) else require(stats)# for dendrogram class & methods
}
