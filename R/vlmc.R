#### $Id: vlmc.R,v 1.27 2002/03/13 10:50:38 maechler Exp $
vlmc.version <- "VLMC 1.3-3;  after $Date: 2002/03/13 10:50:38 $ UTC"
##		      ----- same as the one in ../DESCRIPTION !

vlmc <-
function(dts,
         cutoff.prune =
         	qchisq(alpha.c, df= max(0.1,alpha.len-1), lower.tail=FALSE)/2,
         alpha.c = 0.05,
         threshold.gen = 2,
         y = TRUE, debug = FALSE, quiet = FALSE,
         dump = 0, ctl.dump = c(width.ct = 1+log10(n), nmax.set = -1)
         )
{
  ## Purpose: Fit a VLMC to a discrete time-serie
  ## ----------------------------------------------------------------------
  ## Arguments: dts : numeric / character / factor
  ## ----------------------------------------------------------------------
  ## Author: Martin Mächler, Date: 17 Mar 2000

  cl <- match.call()
  if(is.character(dts)) {
    if(!all(i1 <- (1 == (nc <- nchar(dts)))))
      stop("character argument must have *all* 1-character strings")
  }
  ## common format: factor w/ levels =^= alphabet
  n <- length(f.dts <- as.factor(dts))
  Data <- as.integer(f.dts) - 1:1 #-> is integer in {0,1,...}
  alphabet <- levels(f.dts)# possibly unsorted!
  alpha.len <- length(alphabet)
  if(alpha.len > length(LETTERS))
    stop("alphabet too large; currently limited to maximally 26 letters")
  ialph <- 0:(alpha.len - 1)
  if(any(nchar(alphabet) > 1)) {
    alphabet <- abbreviate(alphabet, min=1)
    if(!quiet)
        warning("alphabet with >1-letter strings; trying to abbreviate")
    if(any(nchar(alphabet) > 1))
      alphabet <-
        if(alpha.len <= 10) as.character(ialph)
        else letters[1:alpha.len]
  }
  Alpha <- paste(alphabet, collapse = "")
  if(debug)
    cat("vlmc: Alpha = '",Alpha,"' ; |X| = ",alpha.len,"\n", sep="")
  ## Check consistency of Data & alphabet :
  idat <- sort(as.integer(names(table(Data))))
  if(!all(ialph == idat)) {
    if(!is.null(xtraD <- setdiff(idat, ialph)))
      stop(paste("Data has 'letters' not in alphabet:",
                 paste(xtraD,collapse=", ")))
    else
        warning("alphabet is larger than set of values in Data")
  }

  dump <- as.integer(dump[1])
  if(dump < 0) stop("`dump' must be non-negative integer")
  if(dump > 0) {
    ctl.dump <- as.integer(ctl.dump)
    if(length(ctl.dump) != 2) stop("`ctl.dump' must be integer(2).")
    if(ctl.dump[2] < 1) # default -- FIXME : should depend also on cutoff..
        ctl.dump[2] <- as.integer(max(6, 15 - log10(n)))
    if(ctl.dump[1] < 0) stop("`ctl.dump[1]' must be non-negative.")
    ## Fixme : need even more consistency checks ..
  }
  if(debug) cat("vlmc: ctl.dump = ",ctl.dump,"\n")

  r <- .C("vlmc_p",
          data   = Data,
          n      = n,
          threshold.gen= as.integer(threshold.gen),
          cutoff.prune = as.double(cutoff.prune),
          alpha.len    = as.integer(alpha.len),
          alpha        = as.character(Alpha),
          debug      = as.integer(as.logical(debug)),
          dump.flags = as.integer(c(dump, ctl.dump)),

          size = integer(4),
          ## Not allowed because of character variable (alpha):
          ## DUP = FALSE,
          PACKAGE = "VLMC")
  ## Now that we know the size of the result, we can "give" the space,
  ## and put the result tree (as integer vector) into it:
  names(r$size) <- c("total","nr.leaves","context","ord.MC")
  r$size <- rev(r$size)
  rvec <- .C("getvlmc",
             size = r$size["total"],
             vlmc.vec = integer(r$size["total"]),
             ##DUP = FALSE,
             PACKAGE = "VLMC")$vlmc

  ## Consistency checks (catch some programming errors):
  if(alpha.len != rvec[1])
      warning(paste(".C(\"vlmc\"..) : |alphabet| inconsistency:",
                    alpha.len, "!=", rvec[1]))
  r$vlmc.vec <- rvec
  if(y) r$y <- alphabet[1:1 + Data]
  r$data <- r$debug <- r$dump.flags <- NULL
  r$call <- cl
  class(r) <- "vlmc"
  r
}

is.vlmc <- function(x)
    inherits(x, "vlmc") && is.integer(x$vlmc.vec) && is.character(x$alpha)

print.vlmc <- function(x, digits = max(3, getOption("digits") - 3), ...)
{
  ## Purpose: "print" Method for "vlmc" objects
  ## ----------------------------------------------------------------------
  ## Author: Martin Mächler, Date: 18 Mar 00, 11:26
  if(!is.vlmc(x)) stop("first argument must be a \"vlmc\" object; see ?vlmc")
  ox <- x
  vvec <- (x $ vlmc.vec)#.Alias
  used.args <- names(x$call)
  cat("\n`vlmc', a Variable Length Markov Chain;\n\t alphabet '",x$alpha,
      "', |alphabet| = ",x$alpha.len,
      ", n = ",x$n,".\nCall: ",deparse(x$call),
      if(!any(used.args %in% c("cutoff.prune","alpha.c")))
      paste(";  default cutoff =", format(x$cutoff,digits=digits)),
      ##";  |result| = ", length(vvec), ", MC order = ", x$size[4],
      "\n -> extensions (= $size ) :\n",sep="")
  print(x $ size)
  cat("AIC = ", format(AIC(x), digits = digits), "\n")
  invisible(ox)
}

### Accessors; well, this may be too extreme OO:
if(FALSE) {
 size <- function(x,...) UseMethod("size")
 size.vlmc <-
  function(x, type = c("ord.MC", "context", "nr.leaves", "total")) x$size[type]
}

summary.vlmc <- function(object, ...)
{
  ## Purpose: "summary" Method for "vlmc" objects
  ## -----------------------------------------------------------
  ## Author: Martin Mächler, Date: 1 Apr 00, 11:26

    p <- predict(object, type = "class")
    conf.tab <- table(data = object$y, predicted = p)
    structure(c(object,
                list(confusion.table = conf.tab,
                     depth.stats = summary(predict(object, type = "depth")[-1]),
                     R2 = sum(diag(conf.tab))/object$n)),
              class = c("summary.vlmc", class(object)))
}

print.summary.vlmc <-
    function(x, digits = getOption("digits"), vvec.printing = FALSE, ...)
{
  ## Purpose: "print" Method for "vlmc.summary" objects
  ## -----------------------------------------------------------
  ## Author: Martin Mächler, Date: 1 Apr 00, 11:30

  print.vlmc(x, digits = digits, ...)
  cat("R^2 = %{correctly predicted} = ",
      format(100 * x$R2, digits= max(2, digits - 3)), "%\n", sep="")
  cat("Confusion matrix:\n")
  print(x$confusion.table, digits = digits, ...)
  cat("Markov chain depths along the data:\n")
  print(noquote(formatC(x$depth.stats, digits = digits)))

  if(FALSE) { ## doesn't make sense anymore
      x$call <- x$vlmv.vec <- NULL
      str(unclass(x), vec.len = 7, digits.d = digits,...)
  }

  if(vvec.printing) {
      vvec <- (x $ vlmc.vec)#.Alias
      if(vvec[1] != x$alpha.len)
          stop("invalid vlmc structure {alpha.len}")
      if((lV <- length(vvec)) > 10000)
          warning("|vvec| > 10000; not printing. Use `prt.vvec()' if you want")
      else {
          cat("\ncontext tree encoding `vvec'tor:\n")
          if(2*lV > getOption("expressions")) {
              oop <- options(expressions = 2*lV)
              on.exit(options(oop))
          }
          prt.vvec(vvec[-1], nalph = vvec[1])
      }
  }

  invisible(x)
} ## print.summary.vlmc

prt.vvec <- function(v, nalph, pad = " ")
{
  ## Purpose: RECURSIVEly print result vector of a vlmc -- not knowing alphabet
  ## ----------------------------------------------------------------------
  ## Author: Martin Mächler, Date: 18 Mar 00, 16:53
  lv <- length(v)
  if(!lv) {
    cat("\n"); return()
  }
  else if(v[1] == -1) {
    cat(" -")
    i <- NULL
  }
  else if (lv <= nalph)
      stop("v[] is not long enough")
  else {
    i <- 1 + 1:nalph
    cat(if(v[1] != 0) "\n",
        sapply(3*v[1], function(n)paste(character(n),collapse= pad)),
        "{",v[1],"} [", paste(formatC(v[i],w=1),collapse=", "), "]", sep="")
  }
  prt.vvec(v[-c(1,i)], nalph, pad = pad)
}

vlmctree <- function(x)
{
  ## Purpose: Compute the Tree representation of a "vlmc" object (as R list).
  ## -------------------------------------------------------------------------
  ## Arguments: x: a "vlmc" object {usually a fit from vlmc(..)}.
  ## -------------------------------------------------------------------------
  ## Author: Martin Maechler, Date:  1 Apr 2000, 18:02
  if(!is.vlmc(x)) stop("first argument must be a \"vlmc\" object; see ?vlmc")
  vvec <- (x $ vlmc.vec)#.Alias
  k <- (x $ alpha.len)#.Alias
  if(vvec[1] != k) stop("invalid vlmc structure {alpha.len}")

  vtree <- .vvec2tree(vvec[-1], k = vvec[1], chk.lev = 0)
}

.vvec2tree <- function(vv, k, chk.lev)
{
  ## Purpose: RECURSIVELY construct tree from a vvec of a "vlmc" object
  ##	      *not* using alphabet, (just k = |alphabet|).
  ## Do as load_tree(.)  {in ../src/io.c }
  ## -------------------------------------------------------------------------
  ## Author: Martin Maechler, Date:  1 Apr 2000, 18:11

  if((lev <- vv[1]) >= 0) { ## non-end
      if(lev != chk.lev)
          stop(paste("malformed vlmc tree at level",chk.lev))

      ii <- 1:k
      node <- list(level = lev, count = vv[1 + ii], child = vector("list", k))
      node $ total <- sum(node $ count)

      vv <- vv[ - c(ii, k+1)]# the first 1..(k+1) ones
      for(i in ii) {
          r <- .vvec2tree(vv, k=k, chk.lev = chk.lev+1)
          if(!is.null(r)) {
              vv <- r[[2]]
              node$child[[i]] <- r[[1]]
          } else vv <- vv[-1] ## child[i] remains NULL
      }
      if(all(sapply(node$child, is.null))) ## this is a leaf
          node$child <- NULL
      if(chk.lev > 0) list(node, vv) else { class(node) <- "vtree";  node }
  }
  ## else return NULL
}

str.vtree <- function(object, ...)
{
    ## Purpose: str method for "vtree" lists  [[recursive]]
    if(!is.null(object$level)) {
        nch <- length(object$child)
        cat(if(object$level)
            paste(rep(" ", object$level+1), collapse="..") else "`vtree':\n",
            format(object$count),"|", object$total, "; ",
            if(nch) paste(nch,"children") else "_leaf_",
            "\n")
        for(ch in object$child)
            str.vtree(ch)
    }
}
