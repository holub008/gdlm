#' Plot a gdlm object
#' 
#' @param the gdlm object to be ploted
#' 
#' @author kholub
#' @examples 
#' m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS())
#' plot(m)
#' 
#' @export plot.gdlm
plot.gdlm <- function(object, ...) {
  hist(residuals(object), xlab = 'Residuals', main = 'GDLM train set residuals')
}