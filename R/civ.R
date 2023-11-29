#' Categorical Instrumental Variable Estimator.
#'
#' @description Implementation of the categorical instrumental variable
#'     estimator.
#'
#' @param y The outcome variable, a numerical vector.
#' @param D A matrix of endogenous variables.
#' @param Z A matrix of instruments, where the first column corresponds to the
#'     categorical instrument.
#' @param X An optional matrix of control variables.
#' @param K The number of support points of the estimated instrument
#'     \eqn{\hat{m}_K}, an integer  greater than 2.
#'
#' @return \code{civ} returns an object of S3 class  \code{civ}. An object of
#'     class \code{civ} is a list containing the following components:
#'     \describe{
#'         \item{\code{coef}}{A vector of second-stage coefficient estimates.}
#'         \item{\code{iv_fit}}{Object of class \code{ivreg} from the IV
#'             regression of \code{y} on \code{D} and \code{X} using the
#'             the estimated \eqn{\hat{F}_K} as an instrument for \code{D}.
#'             See also [AER::ivreg()] for details.}
#'         \item{\code{kcmeans_fit}}{Object of class \code{kcmeans} from the
#'             K-Conditional-Means regression of \code{D} on \code{Z} and
#'             \code{X}. See also [kcmeans::kcmeans()] for details.}
#'         \item{K}{Pass-through of selected user-provided arguments.
#'             See above.}
#'     }
#' @export
#'
#' @references
#' Fox J, Kleiber C, Zeileis A (2023). "ivreg: Instrumental-Variables Regression
#'     by '2SLS', '2SM', or '2SMM', with Diagnostics". R package.
#'
#' Wiemann T (2023). "Optimal Categorical Instruments." https://arxiv.org/abs/2311.17021
#'
#' @examples
#' # Simulate data from a simple IV model with 800 observations
#' nobs = 800 # sample size
#' Z <- sample(1:20, nobs, replace = TRUE) # observed instrument
#' Z0 <- Z %% 2 # underlying latent instrument
#' U_V <- matrix(rnorm(2 * nobs, 0, 1), nobs, 2) %*%
#'   chol(matrix(c(1, 0.6, 0.6, 1), 2, 2)) # first and second stage errors
#' D <- Z0 + U_V[, 2] # endogenous variable
#' y <- D + U_V[, 1] # outcome variable
#' # Estimate categorical instrument variable estimator with K = 2
#' civ_fit <- civ(y, D, Z, K = 3)
#' summary(civ_fit)
civ <- function(y, D, Z, X = NULL, K = 2) {

  # Data parameters
  nobs <- length(y)

  # Estimate the optimal instrument
  ZX <- cbind(Z, X)
  kcmeans_fit <- kcmeans::kcmeans(D, ZX, K = K)
  m_hat <- stats::predict(kcmeans_fit, ZX)

  # Compute TSLS with the estimated optimal instrument
  if (is.null(X)) {
    iv_fit <- AER::ivreg(y ~ D | m_hat)
  } else {
    iv_fit <- AER::ivreg(y ~ D + X | m_hat + X)
  }#IFELSE


  # Prepare and return the model fit object
  civ_fit <- list(coef = iv_fit$coefficients,
                  iv_fit = iv_fit,
                  kcmeans_fit = kcmeans_fit,
                  K = K)
  class(civ_fit) <- "civ" # define S3 class
  return(civ_fit)
}#CIV

#' Inference Methods for the Categorical Instrumental Variable Estimator.
#'
#' @seealso [AER::summary.ivreg()]
#'
#' @description Inference methods for the categorical instrumental variable
#'     estimators. Simple wrapper for [AER::summary.ivreg()].
#'
#' @param object An object of class \code{civ} as fitted by [civ::civ()].
#' @param ... Additional arguments passed to \code{summary.ivreg}. See
#'     [AER::summary.ivreg()] for a complete list of arguments.
#'
#' @return An object of class \code{summary.ivreg} with inference results.
#'
#' @references
#' Fox J, Kleiber C, Zeileis A (2023). "ivreg: Instrumental-Variables Regression
#'     by '2SLS', '2SM', or '2SMM', with Diagnostics". R package.
#'
#' Wiemann T (2023). "Optimal Categorical Instruments." https://arxiv.org/abs/2311.17021
#'
#' @export
#'
#' @examples
#' # Simulate data from a simple IV model with 800 observations
#' nobs = 800 # sample size
#' Z <- sample(1:20, nobs, replace = TRUE) # observed instrument
#' Z0 <- Z %% 2 # underlying latent instrument
#' U_V <- matrix(rnorm(2 * nobs, 0, 1), nobs, 2) %*%
#'   chol(matrix(c(1, 0.6, 0.6, 1), 2, 2)) # first and second stage errors
#' D <- Z0 + U_V[, 2] # endogenous variable
#' y <- D + U_V[, 1] # outcome variable
#' # Estimate categorical instrument variable estimator with K = 2
#' civ_fit <- civ(y, D, Z, K = 3)
#' summary(civ_fit)
summary.civ <- function(object, ...) {
  summary(object$iv_fit, ...)
}#SUMMARY.CIV
