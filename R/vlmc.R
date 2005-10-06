#### $Id: vlmc.R,v 1.33 2005/10/06 12:34:36 maechler Exp $
vlmc.version <- "VLMC 1.3-9;  after $Date: 2005/10/06 12:34:36 $ UTC"
##		      ----- same as the one in ../DESCRIPTION !

vlmc <-
function(dts,
	 cutoff.prune =
		qchisq(alpha.c, df= max(0.1,alpha.len-1), lower.tail=FALSE)/2,
	 alpha.c = 0.05,
	 threshold.gen = 2,
         code1char = TRUE,
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
  if(!is.atomic(dts))
      stop("vlmc() only works on vectors (integer, character, factor)")
  if(is.character(dts)) {
    if(!all(i1 <- (1 == (nc <- nchar(dts)))))
        ## FIXME, change this to a `note()'!
      warning("character argument has elements of more than 1 character")
  }
  ## common format: factor w/ levels =^= alphabet
  n <- length(f.dts <- as.factor(dts))
  Data <- as.integer(f.dts) - 1:1 #-> is integer in {0,1,...}
  alphabet <- levels(f.dts)# possibly unsorted!
  alpha.len <- length(alphabet)
  ## FIXME
  if(alpha.len > length(LETTERS))
    stop("alphabet too large; currently limited to maximally 26 letters")
  ialph <- 0:(alpha.len - 1)
  if(code1char && any(nchar(alphabet) > 1)) {
    if(!quiet)
	warning("alphabet with >1-letter strings; trying to abbreviate")
    alphabet <- abbreviate(alphabet, min=1)
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
    else if(!quiet)
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
	  data	 = Data,
	  n	 = n,
	  threshold.gen= as.integer(threshold.gen),
	  cutoff.prune = as.double(cutoff.prune),
	  alpha.len    = as.integer(alpha.len),
	  alpha	       = as.character(Alpha),
	  debug	     = as.integer(as.logical(debug)),
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
      paste(";	default cutoff =", format(x$cutoff,digits=digits)),
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
