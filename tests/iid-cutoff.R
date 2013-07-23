#### --- Choose cutoff such that  i.i.d. re-sample gives MC(0)
library(VLMC)
data(OZrain)
.proctime00 <- proc.time()

rain4c <- cut(OZrain, c(-.1, 0.5, 18.5, 50.1, 1000))
table(rain4c <- as.integer(rain4c) - 1:1)

fff <- function(x){
    f <- (s <- vlmc(sr4, cut = x)$size)["ord.MC"]
    cat(formatC(x,wid=15)," :  ", formatC(f,wid=2),
        " (",formatC(s["total"],wid=5),")\n", sep="")
    f - 0.01
}

N <- 64# had 200
ur.nms <- c("root", "f.root", "iter", "estim.prec")
r <- matrix(NA, length(ur.nms), N,
            dimnames = list(ur.nms, NULL))
if(R.version$major != "1" || as.numeric(R.version$minor) >= 7) RNGversion("1.6")
set.seed(6352)
for(i in 1:N) {
    sr4 <- sample(rain4c)
    ur <- uniroot(fff, c(1, 20), tol =1e-2)
    r[,i] <- rr <- unlist(ur[ur.nms])
}
rownames(r) <- names(rr)
t(r)
summary( r["root",]) # astonishingly wide; Q1--Q3 =  5.41--6.64
sqrt(var(r["root",]))/ sqrt(N)

hist(r["root",])

## Last Line:
cat('Time elapsed: ', proc.time() - .proctime00,'\n')
