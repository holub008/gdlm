gd_fit <- function(x_data, y_data, loss, initial_estimators) {
  # todo optim may not be the best choice, but it does reduce dependencies. using for now
  # https://www.r-bloggers.com/why-optim-is-out-of-date/
  # additionally need to consider our method more carefully (e.g. stochastic gd)
  estimates <- as.list(optim(par = initial_estimators, X = x_data, y = y_data, fn = loss)$par)
  names(estimates) <- colnames(x_data)

  estimates
}

#' Fit a linear model using an arbitrary loss function
#'
#' Fit a linear model using gradient descent methods. Given a loss function, gdlm will minimize summed loss across observations.
#' Optionally generate bootstrapped standard errors & confidence intervals for estimators.
#' @note It is left to the user to consider the convexity of the summed loss function. For non-convex loss, gradient descent methods may not be generally appropriate.
#' @note The user can control the parallelism of bootstrapping by setting
#'
#' @param formula the form of the linear model to be fit
#' @param data the dataset used to fit the model
#' @param loss a function accepting a vector of parameter estimators, a matrix of training data, and a vector of responses
#' @param bootstrapped_se whether to perform bootstrapping to generate standard errors and confidence intervals
#' @param boostrap_trials how many bootstrap trials to perform
#' @param initial_estimators the starting fit used by gradient descent. default is zeros
#'
#' @author kholub
#' @examples
#' m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS)
#'
#' @importFrom parallel mclapply
#' @importFrom formula.tools lhs.vars
#' @importFrom data.table rbindlist
#'
#' @export gdlm
gdlm <- function(formula, data, loss,
                 bootstrapped_se = TRUE, bootstrap_trials = 100,
                 initial_estimators = NULL) {
  x_data <- model.matrix(formula, data)
  y_name <- lhs.vars(formula)
  if (length(y_name) != 1) {
    stop('Supplied formula must have a single response term. Found ', y_data)
  }
  y_data <- data[[y_name]]

  if (is.logical(y_data)) {
    y_data <- as.integer(y_data)
  }

  if (is.null(initial_estimators)) {
    initial_estimators <- rep(0, ncol(x_data))
  }

  trial_estimators <- NULL
  if (bootstrapped_se) {
    estimates <- mclapply(1:bootstrap_trials, function(trial) {
      bootsamp_ix <- sample(nrow(x_data), replace = TRUE)
      bootsamp_x <- x_data[bootsamp_ix,]
      bootsamp_y <- y_data[bootsamp_ix]

      gd_fit(bootsamp_x, bootsamp_y, loss, initial_estimators)
    })

    trial_estimators <- rbindlist(estimates)
    colnames(trial_estimators) <- colnames(x_data)
  }

  estimators <- unlist(gd_fit(x_data, y_data, loss, initial_estimators))

  structure(list(estimators = estimators,
                 formula = formula,
                 data = x_data,
                 response = y_data,
                 loss = loss,
                 bootstrapped_estimators = trial_estimators),
            class = 'gdlm')
}
