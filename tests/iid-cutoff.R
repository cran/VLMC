#### --- Choose cutoff such that  i.i.d. re-sample gives MC(0)
library(VLMC)
data(OZrain)
.proctime00 <- proc.time()

rain4c <- cut(OZrain, c(-.1, 0.5, 18.5, 50.1, 1000))
table(rain4c <- as.integer(rain4c) - 1:1)

fff <- function(x){
    f <- vlmc(sr4, cut = x)$size["ord.MC"]
    cat(formatC(x,wid=15),": ", formatC(f),"\n")
    f - 0.01
}

N <- 64# had 200
r <- matrix(NA, 4, N)
set.seed(6352)
for(i in 1:N) {
    sr4 <- sample(rain4c)
    r[,i] <- rr <- unlist(uniroot(fff, c(1, 20), tol =1e-2))
}
rownames(r) <- names(rr)
t(r)
summary( r["root",]) # astonishingly wide; Q1--Q3 =  5.41--6.64
sqrt(var(r["root",]))/ sqrt(N)

hist(r["root",])

## Last Line:
cat('Time elapsed: ', proc.time() - .proctime00,'\n')
