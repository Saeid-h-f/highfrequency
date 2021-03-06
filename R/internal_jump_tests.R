
#' ## mukp: to use when p,k different from range [4,6]
#' @importFrom stats rnorm
#' @keywords internal
mukp <- function(p, k, t = 1000000) {
  p <- as.numeric(p)
  k <- as.numeric(k)
  
  U <- rnorm(t)
  Y <- rnorm(t)
  absU <- abs(U)
  mukp <- mean((absU^p)*(abs(U +sqrt(k-1)*Y))^p)
  return(mukp)
}

##fmupk: to use to calculate mupk in the function of the author.
#' @keywords internal
fmupk <- function(p,k){
  mupk <- NULL;
  if (p==2) {
    mupk <- switch(as.character(k),
                  "2" = 4.00,
                  "3" = 5.00,
                  "4" = 6.00)
  }
  if (p==3) {
    mupk <- switch(as.character(k),
                  "2" = 24.07,
                  "3" = 33.63,
                  "4" = 43.74)
  }
  if (p==4) {
    mupk <- switch(as.character(k),
                  "2" = 204.04,
                  "3" = 320.26,
                  "4" = 455.67)
  }
  if (is.null(mupk) == TRUE) {
    # reduce simulation error by taking large T and large nrep
    nrep <- 100
    vmupk <- rep(NA, times = nrep)
    
    for (i in 1:nrep) {
      vmupk[i] <- mukp(p, k, t = 1000000)
    }
    mupk <- round(mean(vmupk),2)
  }
  return(mupk)
}

#' @keywords internal
calculateNpk <- function(p,k){
  mup= 2^(p/2)*gamma(1/2*(p+1))/gamma(1/2)
  mu2p= 2^((2*p)/2)*gamma(1/2*((2*p)+1))/gamma(1/2)
  npk= (1/mup^2)*(k^(p-2)*(1+k)*mu2p + k^(p-2)*(k-1)*mup^2-2*k^(p/2-1) * fmupk(p,k))
  return(npk)
}

#' @keywords internal
calculateV <- function(rse, p, k, N){
  mup <- 2^(p/2)*gamma(1/2*(p+1))/gamma(1/2)
  mu2p <- 2^(p)*gamma(1/2*(2*p+1))/gamma(1/2)
  Ap <- (1/N)^(1-p/2)/mup*sum(rse^p)
  A2p = (1/N)^(1-p)/mu2p*sum(rse^(2*p))
  V <- calculateNpk(p,k) *A2p/(N*Ap^2)
  return(V)
}

#' @keywords internal
scale <- function (align.by) {
  switch(align.by,
         "seconds"= as.numeric(1),
         "minutes"= as.numeric(60),
         "hours"= as.numeric(3600))
}

#Function to calculate simple returns#
#' @keywords internal
simre <- function (pdata) {
  l <- dim(pdata)[1]
  x <- matrix(as.numeric(pdata), nrow = l)
  x[(2:l), ] <- x[(2:l), ]/x[(1:(l - 1)), ]-1
  x[1, ] <- rep(0, dim(pdata)[2])
  x <- xts(x, order.by = index(pdata))
  return(x)
}

tqfun <- function(rdata){ #Calculate the realized tripower quarticity
  returns <- as.vector(as.numeric(rdata));
  n <- length(returns);
  mu43 <- 0.8308609; #    2^(2/3)*gamma(7/6) *gamma(1/2)^(-1)   
  tq <- n * ((mu43)^(-3)) *  sum(abs(returns[1:(n - 2)])^(4/3) *abs(returns[2:(n-1)])^(4/3) *abs(returns[3:n])^(4/3));
  return(tq);
} 
