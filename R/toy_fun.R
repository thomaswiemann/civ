#' Toy function.
#'
#' @family toys
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
toy_fun <- function(y) {
  output <- list(fun = TRUE, y = y)
  class(output) <- "toy_fun" # define S3 class
  return(output)
}#TOY_FUN