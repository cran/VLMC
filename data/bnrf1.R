## data() sets directory
load("bnrf1ebv-cc.rda")#> .dcc is one long string
bnrf1EB <- as.factor(strsplit(.dcc, "")[[1]])
load("bnrf1hvs-cc.rda")
bnrf1HV <- as.factor(strsplit(.dcc, "")[[1]])
rm(.dcc)

## How MM packaged these :
if(FALSE) {
    nuc <- c("a","c","g","t")
    (ddir <- file.path("","archives","Data-Collection","ShumwayStoffer-TSA"))

    nchar(.dcc <- paste(nuc[scan(file.path(ddir,"bnrf1ebv.dat"))], collapse=""))
    setwd("/u/maechler/R/MM/STATISTICS/VLMC/VLMC/data")
    save(.dcc,file="bnrf1ebv-cc.rda")

    nchar(.dcc <- paste(nuc[scan(file.path(ddir,"bnrf1hvs.dat"))], collapse=""))
    save(.dcc,file="bnrf1hvs-cc.rda")
}
