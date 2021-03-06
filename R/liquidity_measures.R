

#' @title Compute Liquidity Measure
#' 
#' Function returns an xts or data.table object containing 23 liquidity measures. Please see details below.
#'
#' Note that this assumes a regular time grid. The Lee + Ready measure
#' uses two lags for the Tick Rule.
#'
#' @param tqdata A \code{data.table} or xts object as in the \pkg{highfrequency} merged
#' trades and quotes data (that is included).
#' @param win A windows length for the forward-prices used for \sQuote{realized}
#' spread
#' @param type Legacy option. Default is to return all liquidity measures.
#' @return A modified (enlarged) \code{xts} or \code{data.table} with the new measures.
#' 
#' @details NOTE: xts or data.table should only contain one day of observations
#' 
#' The respective liquidity measures are defined as follows:
#'   \itemize{
#'     \item{effectiveSpread}{
#'     \deqn{
#'      \mbox{effective spread}_t =  2*D_t*(\mbox{PRICE}_{t} - \frac{(\mbox{BID}_{t}+\mbox{OFR}_{t})}{2}),
#'     }
#'     where \eqn{D_t} is 1 (-1) if \eqn{trade_t} was buy (sell) (see Boehmer (2005), Bessembinder (2003)). 
#'     Note that the input of this function consists of the matched trades and quotes,
#'     so this is were the time indication refers to (and thus not to the registered quote timestamp).
#'   } 
#'   \item{realizedSpread: realized spread}{ 
#'    \deqn{
#'      \mbox{realized spread}_t =  2*D_t*(\mbox{PRICE}_{t} - \frac{(\mbox{BID}_{t+300}+\mbox{OFR}_{t+300})}{2}),
#'    }
#'    
#'    where \eqn{D_t} is 1 (-1) if \eqn{trade_t} was buy (sell) (see Boehmer (2005), Bessembinder (2003)). 
#'    Note that the time indication of \eqn{\mbox{BID}} and \eqn{\mbox{OFR}} refers 
#'    to the registered time of the quote in seconds.
#'  }
#'  
#'  \item{valueTrade: trade value}{ 
#'    \deqn{
#'      \mbox{trade value}_t =  \mbox{SIZE}_{t}*\mbox{PRICE}_{t}.
#'    }
#'  } 
#'  
#'  \item{signedValueTrad: signed trade value}{
#'    \deqn{
#'      \mbox{signed trade value}_t =  D_t * (\mbox{SIZE}_{t}*\mbox{PRICE}_{t}),}
#'    where \eqn{D_t} is 1 (-1) if \eqn{trade_t} was buy (sell) 
#'    (see Boehmer (2005), Bessembinder (2003)).
#'  }  
#'  
#'  \item{depthImbalanceDifference: depth imbalance (as a difference)}{
#'    \deqn{
#'      \mbox{depth imbalance (as difference)}_t =  \frac{D_t *(\mbox{OFRSIZ}_{t}-\mbox{BIDSIZ}_{t})}{(\mbox{OFRSIZ}_{t}+\mbox{BIDSIZ}_{t})},
#'    }
#'    where \eqn{D_t} is 1 (-1) if \eqn{trade_t} was buy (sell) (see Boehmer (2005), Bessembinder (2003)). 
#'    Note that the input of this function consists of the matched trades and quotes,
#'    so this is were the time indication refers to (and thus not to the registered quote timestamp).
#'  } 
#'  
#'  \item{depthImbalanceRatio: depth imbalace (as ratio)}{
#'    \deqn{
#'      \mbox{depth imbalance (as ratio)}_t =  (\frac{\mbox{OFRSIZ}_{t}}{\mbox{BIDSIZ}_{t}})^{D_t},
#'    }
#'    where \eqn{D_t} is 1 (-1) if \eqn{trade_t} was buy (sell) (see Boehmer (2005), Bessembinder (2003)). 
#'    Note that the input of this function consists of the matched trades and quotes,
#'    so this is were the time indication refers to (and thus not to the registered quote timestamp).
#'  } 
#'  
#'  \item{proportionalEffectiveSpread: proportional effective spread}{
#'    \deqn{
#'      \mbox{proportional effective spread}_t =  \frac{\mbox{effective spread}_t}{(\mbox{OFR}_{t}+\mbox{BID}_{t})/2}
#'    }
#'    (Venkataraman, 2001).
#'    
#'    Note that the input of this function consists of the matched trades and quotes,
#'    so this is were the time indication refers to (and thus not to the registered quote timestamp).
#'  } 
#'  
#'  \item{proportionalRealizedSpread: proportional realized spread}{
#'    \deqn{
#'      \mbox{proportional realized spread}_t =  \frac{\mbox{realized spread}_t}{(\mbox{OFR}_{t}+\mbox{BID}_{t})/2}
#'    }
#'    (Venkataraman, 2001).
#'    
#'    Note that the input of this function consists of the matched trades and quotes,
#'    so this is were the time indication refers to (and thus not to the registered 
#'  } 
#'  
#'  \item{priceImpact: price impact}{
#'    \deqn{
#'      \mbox{price impact}_t =  \frac{\mbox{effective spread}_t - \mbox{realized spread}_t}{2}
#'    }
#'    (see Boehmer (2005), Bessembinder (2003)). 
#'  }
#'  
#'  \item{proportionalPriceImpact: proportional price impact}{
#'    \deqn{
#'      \mbox{proportional price impact}_t =  \frac{\frac{(\mbox{effective spread}_t - \mbox{realized spread}_t)}{2}}{\frac{\mbox{OFR}_{t}+\mbox{BID}_{t}}{2}}
#'    }
#'    (Venkataraman, 2001).
#'    Note that the input of this function consists of the matched trades and
#'    quotes, so this is where the time indication refers to (and thus not to the
#'                                                            registered quote timestamp).
#'  }  
#'  
#'  \item{halfTradedSpread: half traded spread}{
#'    \deqn{
#'      \mbox{half traded spread}_t =  D_t*(\mbox{PRICE}_{t} - \frac{(\mbox{BID}_{t}+\mbox{OFR}_{t})}{2}),
#'    }
#'    where \eqn{D_t} is 1 (-1) if \eqn{trade_t} was buy (sell) (see Boehmer (2005), Bessembinder (2003)). 
#'    Note that the input of this function consists of the matched trades and quotes,
#'    so this is were the time indication refers to (and thus not to the registered quote timestamp).
#'  } 
#'  
#'  \item{proportionalHalfTradedSpread: proportional half traded spread}{ 
#'    \deqn{
#'      \mbox{proportional half traded spread}_t =  \frac{\mbox{half traded spread}_t}{\frac{\mbox{OFR}_{t}+\mbox{BID}_{t}}{2}}.
#'    }
#'    Note that the input of this function consists of the matched trades and quotes,
#'    so this is were the time indication refers to (and thus not to the registered quote timestamp).
#'  }
#'  
#'  \item{squaredLogReturn: squared log return on trade prices}{
#'    \deqn{
#'      \mbox{squared log return on Trade prices}_t =  (\log(\mbox{PRICE}_{t})-\log(\mbox{PRICE}_{t-1}))^2.
#'    }
#'  } 
#'  
#'  \item{absLogReturn: absolute log return on trade prices}{
#'    \deqn{
#'      \mbox{absolute log return on Trade prices}_t =  |\log(\mbox{PRICE}_{t})-\log(\mbox{PRICE}_{t-1})|.
#'    }
#'  } 
#'  
#'  \item{quotedSpread: quoted spread}{
#'    \deqn{
#'      \mbox{quoted spread}_t =  \mbox{OFR}_{t}-\mbox{BID}_{t}
#'    }
#'    Note that the input of this function consists of the matched trades and
#'    quotes, so this is where the time indication refers to (and thus not to the
#'                                                            registered quote timestamp).
#'  } 
#'  
#'  \item{proportionalQuotedSpread: proportional quoted spread}{
#'    \deqn{
#'      \mbox{proportional quoted spread}_t =  \frac{\mbox{quoted spread}_t}{\frac{\mbox{OFR}_{t}+\mbox{BID}_{t}}{2}}
#'    }
#'    (Venkataraman, 2001).
#'    Note that the input of this function consists of the matched trades and
#'    quotes, so this is where the time indication refers to (and thus not to the
#'                                                            registered quote timestamp).
#'  }  
#'  
#'  \item{logQuotedSpread: log quoted spread}{
#'    \deqn{
#'      \mbox{log quoted spread}_t =  \log(\frac{\mbox{OFR}_{t}}{\mbox{BID}_{t}})
#'    }
#'    
#'    (Hasbrouck and Seppi, 2001).
#'    Note that the input of this function consists of the matched trades and
#'    quotes, so this is where the time indication refers to (and thus not to the
#'                                                            registered quote timestamp).
#'    
#'  }
#'  
#'  \item{logQuotedSize: log quoted size}{
#'    \deqn{
#'      \mbox{log quoted size}_t =  \log(\mbox{OFRSIZ}_{t})-\log(\mbox{BIDSIZ}_{t})
#'    }
#'    
#'    (Hasbrouck and Seppi, 2001).
#'    Note that the input of this function consists of the matched trades and
#'    quotes, so this is where the time indication refers to (and thus not to the
#'                                                            registered quote timestamp).
#'  } 
#'  
#'  \item{quotedSlope: quoted slope}{
#'    \deqn{
#'      \mbox{quoted slope}_t =  \frac{\mbox{quoted spread}_t}{\mbox{log quoted size}_t}
#'    }
#'    (Hasbrouck and Seppi, 2001).
#'  }
#'  
#'  \item{logQSlope: log quoted slope}{
#'    \deqn{
#'      \mbox{log quoted slope}_t =  \frac{\mbox{log quoted spread}_t}{\mbox{log quoted size}_t}.
#'    }
#'  } 
#'  
#'  \item{midQuoteSquaredReturn: midquote squared return}{
#'    \deqn{
#'      \mbox{midquote squared return}_t =  (\log(\mbox{midquote}_{t})-\log(\mbox{midquote}_{t-1}))^2,
#'    }
#'    
#'    where \eqn{\mbox{midquote}_{t} = \frac{\mbox{BID}_{t} + \mbox{OFR}_{t}}{2}}.
#'  }
#'  
#'  \item{midQuoteAbsReturn: midquote absolute return}{
#'    \deqn{
#'      \mbox{midquote absolute return}_t =  |\log(\mbox{midquote}_{t})-\log(\mbox{midquote}_{t-1})|,
#'    }
#'    
#'    where \eqn{\mbox{midquote}_{t} = \frac{\mbox{BID}_{t} + \mbox{OFR}_{t}}{2}}.
#'  }
#'  
#'  \item{signedTradeSize: signed trade size}{
#'    \deqn{
#'      \mbox{signed trade size}_t =  D_t * \mbox{SIZE}_{t},}
#'    
#'    where \eqn{D_t} is 1 (-1) if \eqn{trade_t} was buy (sell).
#'  }
#'  }
#' 
#' @references  
#' Bessembinder, H. (2003). Issues in assessing trade execution costs. Journal of Financial Markets, 223-257.
#' Boehmer, E. (2005). Dimensions of execution quality: Recent evidence for US equity markets. Journal of Financial Economics 78 (3), 553-582.
#' Hasbrouck, J. and D. J. Seppi (2001). Common factors in prices, order flows and liquidity. Journal of Financial Economics, 383-411.
#' Venkataraman, K. (2001). Automated versus floor trading: An analysis of execution costs on the paris and new york exchanges. The Journal of Finance, 56, 1445-1485.
#' 
#' @examples
#' tqdata <- matchTradesQuotes(sample_tdata, sample_qdata)
#' res <- getLiquidityMeasures(tqdata)
#' head(res)
#' @importFrom data.table shift
#' @export
getLiquidityMeasures <- function(tqdata, win = 300, type = NULL) {
  
  BID = PRICE = OFR = SIZE = OFRSIZ = BIDSIZ = NULL
  
  midpoints = direction = effectiveSpread = realizedSpread = valueTrade = signedValueTrade = NULL
  depthImbalanceRatio = depthImbalanceDifference = proportionalEffectiveSpread = proportionalRealizedSpread = NULL
  priceImpact = proportionalPriceImpact = halfTradedSpread = proportionalHalfTradedSpread = squaredLogReturn = NULL
  squaredLogReturn = absLogReturn = quotedSpread = proportionalQuotedSpread = logQuotedSpread = logQuotedSize = NULL
  quotedSlope = logQSlope = midQuoteSquaredReturn = midQuoteAbsReturn = signedTradeSize = NULL
  
  tqdata <- checkColumnNames(tqdata)
  checktdata(tqdata)
  checkqdata(tqdata)
  
  dummy_was_xts <- FALSE
  if (is.data.table(tqdata) == FALSE) {
    if (is.xts(tqdata) == TRUE) {
      tqdata <- setnames(as.data.table(tqdata), old = "index", new = "DT")
      dummy_was_xts <- TRUE
    } else {
      stop("Input has to be data.table or xts.")
    }
  } else {
    if (("DT" %in% colnames(tqdata)) == FALSE) {
      
      stop("Data.table neeeds DT column (date-time ).")
    }
  }
  
  tqdata[, BID := as.numeric(as.character(BID))]
  tqdata[, PRICE := as.numeric(as.character(PRICE))] # just for being sure
  tqdata[, OFR := as.numeric(as.character(OFR))]      # if one converts from xts back and forth.
  tqdata[, SIZE := as.numeric(as.character(SIZE))]
  tqdata[, OFRSIZ := as.numeric(as.character(OFRSIZ))]
  tqdata[, BIDSIZ := as.numeric(as.character(BIDSIZ))]
  
  tqdata[, midpoints := 0.5 * (BID + OFR)]

  tqdata[, direction := getTradeDirection(tqdata)]
  tqdata[, effectiveSpread := 2 * direction * (PRICE - midpoints)]
  
  tqdata[, realizedSpread := 2 * direction * (PRICE - shift(midpoints, win, type = "lead"))]

  tqdata[, valueTrade := SIZE * PRICE]
  tqdata[, signedValueTrade := direction * valueTrade]

  tqdata[, depthImbalanceDifference := direction * (OFRSIZ - BIDSIZ) / (OFRSIZ + BIDSIZ)]

  tqdata[, depthImbalanceRatio := (direction * OFRSIZ / BIDSIZ) ^ direction]

  tqdata[, proportionalEffectiveSpread := effectiveSpread/midpoints]
  tqdata[, proportionalRealizedSpread := realizedSpread/midpoints]

  tqdata[, priceImpact := (effectiveSpread - realizedSpread)/2]
  tqdata[, proportionalPriceImpact := priceImpact / midpoints]

  tqdata[, halfTradedSpread := direction*(PRICE-midpoints)]
  tqdata[, proportionalHalfTradedSpread := halfTradedSpread/midpoints]

  tqdata[, squaredLogReturn := (log(PRICE) - log(shift(PRICE, 1, type = "lag")))^2]
  tqdata[, absLogReturn := abs(log(PRICE) - log(shift(PRICE, 1, type = "lag")))]

  tqdata[, quotedSpread := OFR - BID]
  tqdata[, proportionalQuotedSpread := quotedSpread/midpoints]

  tqdata[, logQuotedSpread := log(OFR/BID)]
  tqdata[, logQuotedSize := log(OFRSIZ) - log(BIDSIZ)]

  tqdata[, quotedSlope := quotedSpread/logQuotedSize]
  tqdata[, logQSlope := logQuotedSpread/logQuotedSize]

  tqdata[, midQuoteSquaredReturn := (log(midpoints) - log(shift(midpoints,1, type = "lag")))^2]
  tqdata[, midQuoteAbsReturn := abs(log(midpoints) - log(shift(midpoints,1, type = "lag")))]

  tqdata[, signedTradeSize := direction * SIZE]
  
  if (dummy_was_xts == TRUE) {
    if (is.null(type) == TRUE) {
      return(xts(as.matrix(tqdata[, -c("DT")]), order.by = tqdata$DT))
    } else {
      return(xts(as.matrix(tqdata[, -c("DT")]), order.by = tqdata$DT)[, type])
    }
  } else {
    return(tqdata)
  }
}

#' Get trade direction
#' 
#' @description Function returns a vector with the inferred trade direction which is 
#' determined using the Lee and Ready algorithym (Lee and Ready, 1991). 
#' 
#' @param tqdata data.table or xts object, containing joined trades and quotes (e.g. using \code{\link{matchTradesQuotes}})
#' 
#' @details NOTE: The value of the first (and second) observation of the output should be ignored if price == midpoint
#' for the first (second) observation.
#' 
#' @return A vector which has values 1 or (-1) if the inferred trade direction
#' is buy or sell respectively.
#' 
#' @references  Lee, C. M. C. and M. J. Ready (1991). Inferring trade direction from intraday data. Journal of Finance 46, 733-746.
#' 
#' @author Jonathan Cornelissen, Kris Boudt and Onno Kleen. Special thanks to Dirk Eddelbuettel.
#' 
#' @examples 
#' # generate matched trades and quote data set
#' tqdata <- matchTradesQuotes(sample_tdata, sample_qdata)
#' directions <- getTradeDirection(tqdata)
#' head(directions)
#' 
#' @keywords liquidity
#' @export
getTradeDirection <- function(tqdata) {
  
  BID = OFR = PRICE = NULL
  
  tqdata <- checkColumnNames(tqdata)
  checktdata(tqdata)
  checkqdata(tqdata)

  dummy_was_xts <- FALSE
  if (is.data.table(tqdata) == FALSE) {
    if (is.xts(tqdata) == TRUE) {
      tqdata <- setnames(as.data.table(tqdata), old = "index", new = "DT")
      tqdata[, BID := as.numeric(as.character(BID))]
      tqdata[, PRICE := as.numeric(as.character(PRICE))]
      tqdata[, OFR := as.numeric(as.character(OFR))]
      dummy_was_xts <- TRUE
    } else {
      stop("Input has to be data.table or xts.")
    }
  } else {
    if (("DT" %in% colnames(tqdata)) == FALSE) {
      stop("Data.table neeeds DT column (date-time ).")
    }
  }
  
  ## Function returns a vector with the inferred trade direction:
  ## NOTE: the value of the first (and second) observation should be
  ## ignored if price == midpoint for the first (second) observation.
  bid <- tqdata[, BID]
  offer <- tqdata[, OFR]
  midpoints <- (bid + offer)/2
  price <- tqdata[, PRICE]
  
  buy1 <- price > midpoints           # definitely a buy
  equal <- price == midpoints
  
  ## for trades=midpoints: if uptick=>buy (ie p_t - p_{t-1} > 0)
  dif1 <- c(TRUE, 0 < price[2:length(price)] - price[1:(length(price)-1)])
  ## for trades=midpoints: zero-uptick=>buy
  equal1 <- c(TRUE, 0 == price[2:length(price)] - price[1:(length(price)-1)])
  dif2 <- c(TRUE, TRUE, 0 < price[3:length(price)] - price[1:(length(price)-2)])
  
  buy <- buy1 | (dif1 & equal) | (equal1 & dif2 & equal)
  
  buy[buy == TRUE] <- 1                 # 2*as.integer(buy) - 1   does the same
  buy[buy == FALSE] <- -1
  
  
  ## The tick rule is the most commonly used level-1 algorithm. This
  ## rule is rather simple and classifies a trade as buyer-initiated if the
  ## trade price is above the preceding trade price (an uptick trade) and
  ## as seller-initiated if the trade price is below the preceding trade
  ## price (a downtick trade). If the trade price is the same as the
  ## previous trade price (a zero-tick trade), the rule looks for the
  ## closest prior price that differs from the current trade price.
  ## Zero-uptick trades are classified as buys, and zero-downtick trades
  ## are classified as sells.
  ##
  ## -- Chakrabarty, Pascual and Shkilko (2013), "Trade
  ##    Classification Algorithms: A Horse Race between then
  ##    Builk-based and Tick-based Rules"
  ##
  ##    http://dee.uib.es/digitalAssets/234/234006_Pascual.pdf
  
  return(buy)
}

