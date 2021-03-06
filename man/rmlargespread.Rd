% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_handling.R
\name{rmLargeSpread}
\alias{rmLargeSpread}
\title{Delete entries for which the spread is more than "maxi" times the median spread}
\usage{
rmLargeSpread(qdata, maxi = 50)
}
\arguments{
\item{qdata}{an xts or data.table object at least containing the columns "BID" and "OFR".}

\item{maxi}{an integer. By default maxi = "50", which means that entries are deleted 
if the spread is more than 50 times the median spread on that day.}
}
\value{
xts or data.table object depending on input.
}
\description{
Function deletes entries for which the spread is more than "maxi" times the median
spread on that day.
}
\author{
Jonathan Cornelissen and Kris Boudt
}
\keyword{cleaning}
