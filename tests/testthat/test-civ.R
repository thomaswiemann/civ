gen_data <- function(nobs, K0, K, L) {

  # Draw second stage effects
  tau <- c(rep(-0.5, L/2), rep(0.5, L/2))

  # Sample Instrument |supp Q| = K and controls |supp W| = L
  Q <- sample(1:K, nobs, replace = TRUE)
  X <- sample(0:(L-1), nobs, replace = TRUE)
  Z0 <- model.matrix(~ 0 + as.factor(Q)) %*% rep(1:K0, K / K0) - 1
  ZX <- model.matrix(~ 0 + as.factor(Q):as.factor(X))# instrument as indicators
  Z <- ZX %*% c(1:dim(ZX)[2]) # instrument as factor

  # Draw first and second stage errors
  U_V <- matrix(rnorm(2 * nobs, 0, 1), nobs, 2) %*%
    chol(matrix(c(1, 0.8, 0.8, 1), 2, 2))
  # Draw endogenous first stage variable
  D <- as.numeric(Z0 / (K0 - 1) + U_V[, 2])
  # Draw outcome variable
  X_alt <- model.matrix(~ 0 + as.factor(X))
  y <- as.numeric(D * (X_alt %*% tau) + U_V[, 1])

  # Setup dataframe
  SimDat <- data.frame(y = y, D = D, Z0 = Z0, X = X,
                       Z = Z, tau_X = X_alt %*% tau)
  return(SimDat)
}#GEN_DATA

test_that("civ computes w/ and w/o controls", {
  # Generate data
  SimDat <- gen_data(1000, 3, 30, 2)
  # Use data from the included simulated dataset
  y <- SimDat$y
  D <- SimDat$D
  Z <- SimDat$Z
  X <- SimDat$X
  # Estimate civ with and without controls
  civ_fit_wX <- civ(y, D, Z, X, K = 3)
  civ_fit_woX <- civ(y, D, Z, K = 3)
  # Check expectations
  expect_equal(length(civ_fit_wX$coef), 3)
  expect_equal(length(civ_fit_woX$coef), 2)
})#TEST_THAT

#test_that("civ computes w/ controls regularzing E[D|Z]", {
#  # Generate data
#  SimDat <- gen_data(1000, 3, 30, 2)
#  # Use data from the included simulated dataset
#  y <- SimDat$y
#  D <- SimDat$D
#  Z <- SimDat$Z
#  # Estimate civ with and without controls
#  civ_fit_wX <- civ(y, D, Z, K = 3, regularize_EDZ = TRUE)
#  # Check expectations
#  expect_equal(length(civ_fit_wX$coef), 2)
#})#TEST_THAT

test_that("summary.civ computes w/ and w/o controls", {
  # Generate data
  SimDat <- gen_data(1000, 3, 30, 2)
  # Use data from the included simulated dataset
  y <- SimDat$y
  D <- SimDat$D
  Z <- SimDat$Z
  X <- SimDat$X
  # Estimate civ with and without controls
  civ_fit <- civ(y, D, Z, X, K = 3)
  summary_res <- summary(civ_fit)
  # Check expectations
  expect_equal(length(summary_res), 12)
})#TEST_THAT

test_that("civ_select_K recovers known K0 on a large sample", {
  set.seed(42)
  nobs <- 4000
  K0 <- 2L
  Z <- sample(1:20, nobs, replace = TRUE)
  Z0 <- Z %% K0
  U_V <- matrix(rnorm(2 * nobs, 0, 1), nobs, 2) %*%
    chol(matrix(c(1, 0.6, 0.6, 1), 2, 2))
  D <- Z0 + U_V[, 2]
  sel <- civ_select_K(D, Z, K_bar = 5L)
  expect_equal(sel$K, K0)
  expect_equal(names(sel$bic), as.character(2:5))
  expect_true(all(is.finite(sel$bic)))
})#TEST_THAT

test_that("civ with K = 'bic' stores selection and fits", {
  set.seed(7)
  nobs <- 2000
  Z <- sample(1:12, nobs, replace = TRUE)
  Z0 <- Z %% 2
  U_V <- matrix(rnorm(2 * nobs, 0, 1), nobs, 2) %*%
    chol(matrix(c(1, 0.6, 0.6, 1), 2, 2))
  D <- Z0 + U_V[, 2]
  y <- D + U_V[, 1]
  civ_fit <- civ(y, D, Z, K = "bic", K_bar = 4L)
  expect_equal(civ_fit$K, civ_fit$bic$K)
  expect_equal(length(civ_fit$coef), 2)
  expect_error(civ(y, D, Z, K = "bic"), "'K_bar'")
})#TEST_THAT
