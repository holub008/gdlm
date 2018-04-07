#' Produce residuals from a gradient descent generated linear model
#'
#' @param object model to generate residuals for
#' @param type the scale on which to generate residuals
#'
#' @author kholub
#' @examples
#' m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS())
#' residuals(m)
#' 
#' @export
residuals.gdlm <- function(object, type = c("working", "response")){
  # todo this is funky for glms
  object$response - predict(object)
}
