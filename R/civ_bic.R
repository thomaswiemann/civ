#' BIC for the number of latent instrument support points.
#'
#' Computes the Bayesian information criterion from Appendix B of
#' Wiemann (2023) for selecting \eqn{K} given an upper bound
#' \eqn{\bar{K}}:
#' \deqn{\mathrm{BIC}(K) = n \ln(\mathbb{E}_n(D_i - \hat{m}_K^{(n)}(Z_i))^2)
#'   + K |\mathcal{Z}^{(n)}| \ln(n).}
#' Returns
#' \eqn{\hat{K} = \arg\min_{K \in \{2,\ldots,\bar{K}\}} \mathrm{BIC}(K)}.
#'
#' @param D A numeric vector of endogenous variables (or a one-column matrix).
#' @param Z A matrix of instruments, where the first column corresponds to the
#'     categorical instrument (or a vector / factor for that instrument).
#' @param X An optional matrix of control variables.
#' @param K_bar Known upper bound on \eqn{K_0}, an integer with
#'     \eqn{2 \le \bar{K} \le |\mathcal{Z}^{(n)}|}.
#' @param regularize_EDZ A boolean indicating whether \eqn{E[D|Z]} should be
#'     regularized directly rather than \eqn{E[D - X^\top\pi\vert Z]}.
#'
#' @return A list with components:
#' \describe{
#'   \item{\code{K}}{Selected \eqn{\hat{K}}.}
#'   \item{\code{bic}}{Named numeric vector of BIC values for each
#'     \eqn{K \in \{2,\ldots,\bar{K}\}}.}
#'   \item{\code{n_levels}}{Cardinality \eqn{|\mathcal{Z}^{(n)}|} used in
#'     the penalty term.}
#' }
#'
#' @references
#' Wiemann T (2023). "Optimal Categorical Instruments."
#'     https://arxiv.org/abs/2311.17021
#'
#' @export
#'
#' @examples
#' set.seed(1)
#' nobs <- 2000
#' Z <- sample(1:20, nobs, replace = TRUE)
#' Z0 <- Z %% 2
#' U_V <- matrix(rnorm(2 * nobs), nobs, 2) %*%
#'   chol(matrix(c(1, 0.6, 0.6, 1), 2, 2))
#' D <- Z0 + U_V[, 2]
#' sel <- civ_select_K(D, Z, K_bar = 5)
#' sel$K
civ_select_K <- function(D, Z, X = NULL, K_bar, regularize_EDZ = FALSE) {
  D <- as.numeric(D)
  nobs <- length(D)
  if (nobs < 2L) {
    stop("'D' must have length at least 2.", call. = FALSE)
  }
  if (missing(K_bar) || is.null(K_bar)) {
    stop("'K_bar' must be supplied.", call. = FALSE)
  }
  K_bar <- as.integer(K_bar)[1L]
  if (is.null(dim(Z))) {
    Z_cat <- Z
  } else {
    Z_cat <- Z[, 1L]
  }
  n_levels <- length(unique(Z_cat))
  if (K_bar < 2L || K_bar > n_levels) {
    stop("'K_bar' must satisfy 2 <= K_bar <= |Z| (", n_levels, ").",
         call. = FALSE)
  }

  K_grid <- 2L:K_bar
  bic <- setNames(rep(NA_real_, length(K_grid)), as.character(K_grid))
  for (K in K_grid) {
    if (regularize_EDZ) {
      Z_use <- if (is.null(dim(Z))) cbind(Z) else Z
      kcmeans_fit <- kcmeans::kcmeans(D, Z_use, K = K)
      m_hat <- stats::predict(kcmeans_fit, Z_use)
    } else {
      ZX <- cbind(Z, X)
      kcmeans_fit <- kcmeans::kcmeans(D, ZX, K = K)
      m_hat <- stats::predict(kcmeans_fit, ZX)
    }
    sigma2 <- mean((D - as.numeric(m_hat))^2)
    if (!is.finite(sigma2) || sigma2 <= 0) {
      bic[as.character(K)] <- Inf
    } else {
      bic[as.character(K)] <- nobs * log(sigma2) + K * n_levels * log(nobs)
    }
  }

  K_hat <- as.integer(names(bic)[which.min(bic)])
  list(K = K_hat, bic = bic, n_levels = n_levels)
}
