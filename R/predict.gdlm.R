#' Generate predictions from a gradient descent generated linear model
#'
#' @param object model to generate predictions from
#' @param newdata data to predict responses for
#' @param type the scale on which to generate residuals
#'
#' @author kholub
#' @examples
#' m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS)
#' predict(m)
#'
#' @export predict.gdlm
predict.gdlm <- function(object, newdata = NULL, type = c("working", "response"), ...){
  # todo type is ignored, not sure about best way to handle this... maybe just let the user deal with it?
  # the correct solution is probably to make loss_function a typed object that optionally includes a link function

  if (is.null(newdata)) {
    x_data <- object$data
  }
  else {
    # TODO handling new levels: should be configurable to ignore / relevel such observations
    x_data <- if(is.data.frame(newdata)) model.matrix(object$formula, newdata) else newdata
  }
  x_data %*% object$estimators
}
