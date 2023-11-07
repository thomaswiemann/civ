test_that("kcmenas computes", {
  # Get data from the included SimDat data
  y <- SimDat$D
  X <- SimDat$Z

  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)

  # Check output with expectations
  expect_equal(dim(kcmeans_fit), c(60, 5))
})#TEST_THAT

test_that("kcmenas computes with additional controls", {
  # Get data from the included SimDat data
  y <- SimDat$D
  X <- cbind(SimDat$Z, SimDat$X)


  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)

  # Check output with expectations
  expect_equal(dim(kcmeans_fit), c(60, 5))
})#TEST_THAT

test_that("predict.kcmenas computes w/ unseen categories", {
  # Get data from the included SimDat data
  y <- SimDat$D
  X <- cbind(SimDat$Z, SimDat$X)

  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)

  # Compute predictions w/ unseen categories
  newdata <- X
  newdata[1:20, 1] <- -22

  fitted_values <- predict(kcmeans_fit, newdata)

  # Check output with expectations
  expect_equal(dim(kcmeans_fit), c(60, 5))
})#TEST_THAT
