test_that("civ computes w/ and w/o controls", {
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
