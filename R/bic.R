#' Select K for [civ()] by BIC.
#'
#' Calls [kcmeans::bic()] on the first-stage design [civ()] uses and returns
#' that selection. Pass \code{$K} to [civ()].
#'
#' With \code{regularize_EDZ = FALSE} the call is
#' \code{kcmeans::bic(D, cbind(Z, X), K_bar = K_bar)}. With
#' \code{regularize_EDZ = TRUE} it is \code{kcmeans::bic(D, Z, K_bar = K_bar)}.
#'
#' @inheritParams civ
#' @param K_bar Upper bound passed to [kcmeans::bic()].
#'
#' @return The list returned by [kcmeans::bic()].
#'
#' @export
#'
#' @examples
#' nobs <- 800
#' Z <- sample(1:20, nobs, replace = TRUE)
#' Z0 <- Z %% 2
#' U_V <- matrix(rnorm(2 * nobs, 0, 1), nobs, 2) %*%
#'   chol(matrix(c(1, 0.6, 0.6, 1), 2, 2))
#' D <- Z0 + U_V[, 2]
#' y <- D + U_V[, 1]
#' sel <- bic(D, Z, K_bar = 4)
#' civ(y, D, Z, K = sel$K)
bic <- function(D, Z, X = NULL, K_bar, regularize_EDZ = FALSE) {
  design <- if (regularize_EDZ) Z else cbind(Z, X)
  kcmeans::bic(D, design, K_bar = K_bar)
}#BIC
