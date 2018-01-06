#' Produce a summary for a gradient descent generated linear model
#'
#' This summary will include model details, coefficient estimates, & bootstrapped SEs and bootstrap CIs if the gdlm was constructed with boostrapping enabled
#'
#' @param object model to summarize
#' @param ci_range a vector of the lower and upper bounds for empirical confidence intervals
#'
#' @author kholub
#' @examples
#' m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS())
#' summary(m)
#'
#' @export summary.gdlm
summary.gdlm <- function(object, ci_range = c(.05, .95), ...){
  final_table <- cbind(Estimate = object$estimators)

  if (!is.null(object$bootstrapped_estimators)) {
    predictor_ses <- apply(object$bootstrapped_estimators, 2, sd)
    predictor_cis <- t(apply(object$bootstrapped_estimators, 2, function(bootsamp){
      quantile(bootsamp, probs = ci_range)
    }))

    final_table <- cbind(final_table, "Standard Error" = predictor_ses, "CI" = predictor_cis)
  }

  # todo would also be helpful to print the initial loss call
  structure(list(formula = formula(object),
                 estimator_summary = final_table),
            class = 'summary.gdlm')
}

#' Print a gdlm summary
#'
#' @param object the summary.gdlm object to be printed
#'
#' @author kholub
#' @examples
#' m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS())
#' print(summary(m))
#'
#' @export print.summary.gdlm
print.summary.gdlm <- function(object, ...) {
  cat('Formula:', deparse(object$formula), '\n\n')
  cat('Estimators:\n')
  print(object$estimator_summary)
}

#' Retrieve the formula from a gdlm object
#'
#' @param object the gdlm object from which to retrieve a formula
#'
#' @author kholub
#' @examples
#' m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS())
#' print(summary(m))
#'
#' @export formula.gdlm
formula.gdlm <- function(object, ...) {
  object$formula
}
