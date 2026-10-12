test_that("bic() returns kcmeans::bic on civ()'s first-stage design", {
  set.seed(1)
  nobs <- 600
  Z <- sample(1:12, nobs, replace = TRUE)
  X <- rnorm(nobs)
  D <- (Z %% 2) + 0.3 * X + rnorm(nobs)

  sel <- kcmeans::bic(D, cbind(Z, X), K_bar = 4)
  expect_equal(bic(D, Z, X, K_bar = 4), sel)

  sel_r <- kcmeans::bic(D, Z, K_bar = 4)
  expect_equal(bic(D, Z, X, K_bar = 4, regularize_EDZ = TRUE), sel_r)
})
