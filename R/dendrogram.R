####- vlmctree() & as.dendrogram() --- R-level recursive tree construction

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
  ## Do as load_tree(.)	 {in ../src/io.c }
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
          vv <-
              if(!is.null(r)) {
                  node$child[[i]] <- r[[1]]
                  r[[2]]
              } else vv[-1] ## child[i] remains NULL
      }
      node$level[2] <- ## parent level :
          if(all(sapply(node$child, is.null))) { ## this is a leaf
              node$child <- NULL
              0 # parent level
          } else 1:1 + max(sapply(node$child, function(n)
                                  if(is.null(n)) 0 else n$level[2]))
      node$level <- as.integer(node$level)
      if(lev > 0)
	  list(node, vv)
      else { ## toplevel
	  class(node) <- "vtree"
	  node
      }
  }
  ## else return NULL
}

str.vtree <- function(object, ...)
{
    ## Purpose: str method for "vtree" lists  [[recursive]]
    if(!is.null(lev <- object$level)) {
	nch <- length(object$child)
	cat(if(lev[1])
	    paste(rep(" ", lev[1]+1), collapse="..") else "`vtree':\n",
            paste("{", lev[2],"}", sep=""),
	    format(object$count),"|", object$total, "; ",
	    if(nch) paste(nch,"children") else "_leaf_",
	    "\n")
	for(ch in object$child)
	    str.vtree(ch, ...)
    }
}


###- as.dendrogram() method - in order to plot the context - tree

## Generic and hclust method are in
##  ~/R/D/r-devel/R/src/library/mva/R/dendrogram.R

### FIXME:
### =====
## 1) Add "midpoint" such that I can plot with center = FALSE
## 2) Allow "height" of leave to be  parent_height -1 !
as.dendrogram.vlmc <- function(object, ...)
{
    if(!is.vlmc(object))
        stop("first argument must be a \"vlmc\" object; see ?vlmc")
    vvec <- (object $ vlmc.vec)#.Alias
    k <- (object $ alpha.len)#.Alias
    if(vvec[1] != k) stop("invalid vlmc structure {alpha.len}")

    vv2dendro <- function(vv, cl.lev)
    {
        ## workhorse (recursive!)
        if((lev <- vv[1]) >= 0) { ## non-end
            if(lev != cl.lev)
                stop(paste("malformed vlmc tree at level",cl.lev))

            ii <- 1:k
            node <- vector("list", k)
            count <- vv[1 + ii]
            vv <- vv[ - c(ii, k+1)]     # the first 1..(k+1) ones
            for(i in ii) { ## extract child[i]
                r <- vv2dendro(vv, cl.lev = cl.lev+1)
                vv <-
                    if(!is.null(r)) {
                        node[[i]] <- r[[1]]
                        r[[2]]
                    } else ## empty child[i]; drop node[[i]] (NULL) later
                vv[-1]
            }
            ##- cat("lev=",lev,";", "count=",count,"  vv : \n"); str(vv)
            if(all(sapply(node, is.null))) { ## this is a leaf
                node <- sum(count)
                attr(node,"height") <- 0:0
                attr(node,"members") <- 1:1
            } else {
                ## drop the NULL children:
                node <- node[sapply(node,function(n)!is.null(n))]
                attr(node,"height") <- ## parent level :
                    1:1 + max(sapply(node, function(n) attr(n,"height")))
                attr(node,"members") <- ## parent level :
                    sum(sapply(node, function(n) attr(n,"members")))
            }

            list(node, vv)
        }
        ## else lev = -1 :  return NULL
    }

    r <- vv2dendro(vvec[-1], 0)[[1]]
    class(r) <- "dendrogram"
    r
}

