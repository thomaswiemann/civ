#' First stage estimator.
#'
#' @description This is a simple toy function.
#'
#' @param x A numerical vector.
#'
#' @return \code{toy_fun} returns an object of S3 class
#'     \code{toy_fun}. An object of class \code{toy_fun} is a list containing
#'     the following components:
#'     \describe{
#'         \item{\code{fun}}{A boolean on whether you had fun..}
#'         \item{\code{y}}{Pass-through of the ser-provided arguments.
#'             See above.}
#'     }
#' @export
#'
#' @examples
#' res <- toy_fun(rnorm(100))
#' res$fun
kcmeans <- function(y, X, K) {

  # Data parameters
  nobs <- length(y)

  # Check whether additional features are included, residualize accordingly
  if (length(X) > nobs) {
    Z <- X[, 1] # categorical variable
    X <- X[, -1, drop = FALSE] # additional features
    # Compute \pi and residualize y
    nX <- ncol(X)
    Z_mat <- model.matrix(~ 0 + as.factor(Z))
    ols_fit <- ols(y, cbind(X, Z_mat)) # ols w/ generalized inverse
    pi <- ols_fit$coef[1:nX]
    y <- y - X %*% pi
  } else {
    Z <- X # categorical variable
    pi <- NULL
  }#IFELSE

  # Prepare data and prepare the cluster map
  unique_Z <- unique(Z)
  cluster_map <- t(simplify2array(lapply(unique_X, function (x) {
    c(x, mean(y[Z == x]), mean(Z == x))
    })))#LAPPLY

  # Estimate kmeans on means of D given Z = z
  kmeans_fit <- Ckmeans.1d.dp::Ckmeans.1d.dp(x = cluster_map[, 2], k = K,
                                             y = cluster_map[, 3])

  # Amend the cluster map
  cluster_map <- cbind(cluster_map, kmeans_fit$cluster,
                   kmeans_fit$centers[kmeans_fit$cluster])
  colnames(cluster_map) <- c("x", "EYx", "Px", "gx", "mx")

  # Compute the unconditional mean
  mean_y <- mean(y)

  # Prepare and return the model fit object
  mdl_fit <- list(cluster_map = cluster_map,
                  mean_y = mean_y, pi = pi)
  class(mdl_fit) <- "kcmeans" # define S3 class
  return(mdl_fit)
}#kcmeans


#' Inference Methods for Partially Linear Estimators.
#'
#' @seealso [sandwich::vcovHC()]
#'
#' @description Inference methods for partially linear estimators. Simple
#'     wrapper for [sandwich::vcovHC()].
#'
#' @param object An object of class \code{ddml_plm}, \code{ddml_pliv}, or
#'     \code{ddml_fpliv} as fitted by [ddml::ddml_plm()], [ddml::ddml_pliv()],
#'     and [ddml::ddml_fpliv()], respectively.
#' @param ... Additional arguments passed to \code{vcovHC}. See
#'     [sandwich::vcovHC()] for a complete list of arguments.
#'
#' @return An array with inference results for each \code{ensemble_type}.
#'
#' @references
#' Zeileis A (2004). "Econometric Computing with HC and HAC Covariance Matrix
#'     Estimators.” Journal of Statistical Software, 11(10), 1-17.
#'
#' Zeileis A (2006). “Object-Oriented Computation of Sandwich Estimators.”
#'     Journal of Statistical Software, 16(9), 1-16.
#'
#' Zeileis A, Köll S, Graham N (2020). “Various Versatile Variances: An
#'     Object-Oriented Implementation of Clustered Covariances in R.” Journal of
#'     Statistical Software, 95(1), 1-36.
#'
#' @export
#'
#' @examples
#' # Construct variables from the included Angrist & Evans (1998) data
#' y = AE98[, "worked"]
#' D = AE98[, "morekids"]
#' X = AE98[, c("age","agefst","black","hisp","othrace","educ")]
#'
#' # Estimate the partially linear model using a single base learner, ridge.
#' plm_fit <- ddml_plm(y, D, X,
#'                     learners = list(what = mdl_glmnet,
#'                                     args = list(alpha = 0)),
#'                     sample_folds = 2,
#'                     silent = TRUE)
#' summary(plm_fit)
predict.kcmeans <- function(object, newdata, clusters = FALSE, ...) {

  # Check whether additional features are included, compute X\pi if needed
  if (!is.null(object$pi)) {
    Z <- newdata[, 1]
    X <- newdata[, -1, drop = FALSE]
    if(!clusters) Xpi <- X %*% object$pi
  } else {
    Z <- newdata
    Xpi <- 0
  }#IFELSE

  # Construct fitted values from cluster map
  fitted_mat <- merge(Z, object$cluster_map,
                      by.x = 1, by.y = 1, all.x = TRUE)

  # Construct predictions
  if (clusters) {
    # Return estimated cluster assignment
    return(fitted_mat[, "gx"])
  } else {
    # Replace unseen categories with unconditional mean of y - X\pi
    fitted_mat[is.na(fitted_mat[, "mx"]), 5] <- object$mean_y
    # Construct and return fitted values
    fitted <- fitted_mat[, "mx"] + Xpi
    return(fitted)
  }#IFELSE

}#PREDICT.KCMEANS
