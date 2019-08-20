% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/realized_measures.R
\name{rRTSCov}
\alias{rRTSCov}
\title{Robust two time scale covariance estimation}
\usage{
rRTSCov(pdata, cor = FALSE, startIV = NULL, noisevar = NULL,
  K = 300, J = 1, K_cov = NULL, J_cov = NULL, K_var = NULL,
  J_var = NULL, eta = 9, makePsd = FALSE)
}
\arguments{
\item{pdata}{a list. Each list-item i contains an xts object with the intraday price data 
of stock i for day t.}

\item{cor}{boolean, in case it is TRUE, the correlation is returned. FALSE by default.}

\item{startIV}{vector containing the first step estimates of the integrated variance of the assets, needed in the truncation. Is NULL by default.}

\item{noisevar}{vector containing the estimates of the noise variance of the assets, needed in the truncation. Is NULL by default.}

\item{K}{positive integer, slow time scale returns are computed on prices that are K steps apart.}

\item{J}{positive integer, fast time scale returns are computed on prices that are J steps apart.}

\item{K_cov}{positive integer, for the extradiagonal covariance elements the slow time scale returns are computed on prices that are K steps apart.}

\item{J_cov}{positive integer, for the extradiagonal covariance elements the fast time scale returns are computed on prices that are J steps apart.}

\item{K_var}{vector of positive integers, for the diagonal variance elements the slow time scale returns are computed on prices that are K steps apart.}

\item{J_var}{vector of positive integers, for the diagonal variance elements the fast time scale returns are computed on prices that are J steps apart.}

\item{eta}{positive real number, squared standardized high-frequency returns that exceed eta are detected as jumps.}

\item{makePsd}{boolean, in case it is TRUE, the positive definite version of rRTSCov is returned. FALSE by default.}
}
\value{
an \eqn{N x N} matrix
}
\description{
Function returns the robust two time scale covariance matrix proposed in Boudt and Zhang (2010). 
Unlike the \code{\link{rOWCov}}, but similarly to the \code{\link{rThresholdCov}}, the rRTSCov uses  univariate jump detection rules 
to truncate the effect of jumps on the covariance 
estimate. By the use of two time scales, this covariance estimate 
is not only robust to price jumps, but also to microstructure noise and non-synchronic trading.
}
\details{
The rRTSCov requires the tick-by-tick transaction prices. (Co)variances are then computed using log-returns calculated on a rolling basis 
on stock prices that are \eqn{K} (slow time scale) and \eqn{J} (fast time scale) steps apart.     

The diagonal elements of the rRTSCov matrix are the variances, computed for log-price series \eqn{X} with \eqn{n} price observations 
at times \eqn{  \tau_1,\tau_2,\ldots,\tau_n} as follows: 
\deqn{
(1-\frac{\overline{n}_K}{\overline{n}_J})^{-1}(\{X,X\}_T^{(K)^{*}}-\frac{\overline{n}_K}{\overline{n}_J}\{X,X\}_T^{(J)^{*}}),
}
where \eqn{\overline{n}_K=(n-K+1)/K},  \eqn{\overline{n}_J=(n-J+1)/J} and 
\deqn{\{X,X\}_T^{(K)^{*}} =\frac{c_\eta^{*}}{K}\frac{\sum_{i=1}^{n-K+1}(X_{t_{i+K}}-X_{t_i})^2I_X^K(i;\eta)}{\frac{1}{n-K+1}\sum_{i=1}^{n-K+1}I_X^K(i;\eta)}.} 
The constant  \eqn{c_\eta} adjusts for the bias due to the thresholding  and \eqn{I_{X}^K(i;\eta)} is a jump indicator function
that is one if 
\deqn{ \frac{(X_{t_{i+K}}-X_{t_{i}})^2}{(\int_{t_{i}}^{t_{i+K}} \sigma^2_sds +2\sigma_{\varepsilon_{\mbox{\tiny X}}}^2)}  \ \ \leq  \ \    \eta } 
and zero otherwise.  The elements in the denominator are the integrated variance (estimated recursively) and noise variance (estimated by the method in Zhang et al, 2005). 

The extradiagonal elements of the rRTSCov are the covariances. 
For their calculation, the data is first synchronized by the refresh time method proposed by Harris et al (1995).
It uses the function \code{\link{refreshTime}} to collect first the so-called refresh times at which all assets have traded at least once 
since the last refresh time point. Suppose we have two log-price series:  \eqn{X} and \eqn{Y}. Let \eqn{ \Gamma =\{ \tau_1,\tau_2,\ldots,\tau_{N^{\mbox{\tiny X}}_{\mbox{\tiny T}}}\}} and 
\eqn{\Theta=\{\theta_1,\theta_2,\ldots,\theta_{N^{\mbox{\tiny Y}}_{\mbox{\tiny T}}}\}} 
be the set of transaction times of these assets. 
The first refresh time corresponds to the first time at which both stocks have traded, i.e. 
\eqn{\phi_1=\max(\tau_1,\theta_1)}. The subsequent refresh time is defined as the first time when both stocks have again traded, i.e.
\eqn{\phi_{j+1}=\max(\tau_{N^{\mbox{\tiny{X}}}_{\phi_j}+1},\theta_{N^{\mbox{\tiny{Y}}}_{\phi_j}+1})}. The
complete refresh time sample grid is 
\eqn{\Phi=\{\phi_1,\phi_2,...,\phi_{M_N+1}\}}, where \eqn{M_N} is the total number of paired returns.  The
sampling points of asset \eqn{X} and \eqn{Y} are defined to be
\eqn{t_i=\max\{\tau\in\Gamma:\tau\leq \phi_i\}} and
\eqn{s_i=\max\{\theta\in\Theta:\theta\leq \phi_i\}}.

Given these refresh times, the covariance is computed as follows: 
\deqn{
c_{N}( \{X,Y\}^{(K)}_T-\frac{\overline{n}_K}{\overline{n}_J}\{X,Y\}^{(J)}_T ),
}

where
\deqn{\{X,Y\}^{(K)}_T =\frac{1}{K} \frac{\sum_{i=1}^{M_N-K+1}c_i (X_{t_{i+K}}-X_{t_{i}})(Y_{s_{i+K}}-Y_{s_{i}})I_{X}^K(i;\eta)
I_{Y}^K(i;\eta)}{\frac{1}{M_N-K+1}\sum_{i=1}^{M_N-K+1}{I_X^K(i;\eta)I_Y^K(i;\eta)}},}
with  \eqn{I_{X}^K(i;\eta)} the same jump indicator function as for the variance and \eqn{c_N} a constant to adjust for the bias due to the thresholding.  

Unfortunately, the rRTSCov is not always positive semidefinite.  
By setting the argument makePsd = TRUE, the function  \code{\link{makePsd}} is used to return a positive semidefinite
matrix. This function replaces the negative eigenvalues with zeroes.
}
\examples{
# Robust Realized two timescales Variance/Covariance
data(sample_tdata)
# Univariate: 
rvRTS <- rRTSCov(pdata = sample_tdata$PRICE)
# Note: Prices as input
rvRTS 

# Multivariate:
rcRTS <- rRTSCov(pdata = list(cumsum(lltc) + 100, cumsum(sbux) + 100))
# Note: List of prices as input
rcRTS 

}
\references{
Boudt K. and Zhang, J. 2010. Jump robust two time scale covariance estimation and realized volatility budgets. Mimeo.

Harris, F., T. McInish, G. Shoesmith, and R. Wood (1995). Cointegration, error correction, and price discovery on infomationally linked security markets. Journal of Financial and Quantitative Analysis 30, 563-581.

Zhang, L., P. A. Mykland, and Y. Ait-Sahalia (2005). A tale of two time scales: Determining integrated volatility with noisy high-frequency data. Journal of the American Statistical Association 100, 1394-1411.
}
\author{
Jonathan Cornelissen and Kris Boudt
}
\keyword{volatility}
