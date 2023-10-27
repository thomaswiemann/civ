test_that("toy_fun computes", {
  # Run toy_fun
  myfun <- toy_fun(rnorm(10))$fun
  # Check output with expectations
  expect_equal(length(myfun), 1)
})#TEST_THAT
