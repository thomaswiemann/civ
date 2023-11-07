
# Data parameters
nobs = 1000
K0 = 3
K = 30
L = 2

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
SimDat <- data.frame(y = y, D = D, Z0 = Z0, X = X, Z = Z, tau_X = X_alt %*% tau)

# Use data in package
usethis::use_data(SimDat, overwrite = TRUE)
