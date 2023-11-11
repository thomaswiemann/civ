
<!-- README.md is generated from README.Rmd. Please edit that file -->

# civ

<!-- badges: start -->

[![R-CMD-check](https://github.com/thomaswiemann/civ/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thomaswiemann/civ/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/thomaswiemann/civ/branch/main/graph/badge.svg?token=PHB9W2TJ6S)](https://app.codecov.io/gh/thomaswiemann/civ)
[![CodeFactor](https://www.codefactor.io/repository/github/thomaswiemann/civ/badge)](https://www.codefactor.io/repository/github/thomaswiemann/civ)
<!-- badges: end -->

`civ` is an implementation of the categorical instrumental variable
estimator as proposed by Wiemann (2023). The key feature of `civ` is
optimal instrumental variable estimation in settings with relatively few
observations per category by leveraging a regularization assumption that
implies existence of a latent categorical variable with fixed finite
support achieving the same first stage fit as the observed instrument.

## Installation

Install the latest development version from GitHub (requires
[devtools](https://github.com/r-lib/devtools) package):

``` r
if (!require("devtools")) {
  install.packages("devtools")
}
devtools::install_github("thomaswiemann/civ", dependencies = TRUE)
```
