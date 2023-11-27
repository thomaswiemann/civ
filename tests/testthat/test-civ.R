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
