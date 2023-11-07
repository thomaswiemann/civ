#' Simulated data from the DGP of Wiemann (2023).
#'
#' @description Simulated data from the DGP of Wiemann (2023).
#'
#' @format A data frame with 1000 rows and 6 variables.
#' \describe{
#'   \item{y}{The outcome.}
#'   \item{D}{The endogenous variable.}
#'   \item{Z0}{The (in practice unobserved) low-dimensional categorical
#'       instrument.}
#'   \item{Z}{The (in practice observed) higher-dimensional categorical
#'       instrument.}
#'   \item{X}{A binary control variable.}
#'   \item{tau_X}{The (in practice unobserved) second-stage coefficient.}
#' }
#'
#' @references
#' Wiemann (2023). "Optimal Categorical Instruments."
"SimDat"
