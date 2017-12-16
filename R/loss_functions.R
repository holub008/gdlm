# todo: na handling
# todo: numeric instabilities for ex. log loss

#' Compute qausi least squares loss function
#'
#' @param estimators coefficient estimators
#' @param X the data on which to evaluate loss
#' @param y the responses corresponding to y
#' @param loss_asymmetry the assymetry in [0,1] attached to under/over predictions. Closer to 0, underpredictions are penalized; Closer to 1, overpredictions are penalized.
#'
#' @author kholub
#' @examples
#' estimators <- c(1,2)
#' X <- matrix(c(1,2,3,4), nrow = 2)
#' y <- c(6, 11)
#' ls_loss(estimators, X, y)
#'
#' @export ls_loss
ls_loss <- function(estimators, X, y, loss_asymmetry = .5) {
  stopifnot(loss_asymmetry <= 1 && loss_asymmetry >= 0)

  predictions <- X %*% estimators
  errors <- y - predictions
  loss_scaling <- abs(loss_asymmetry - as.integer(errors < 0))
  mean(loss_scaling * errors ^ 2)
}

#' Parameterize a quasi least squares loss function
#'
#' A convinience to create a function delegating to ls_loss
#'
#' @param loss_asymmetry parameter passed to ls_loss
#'
#' @export LS_LOSS
LS_LOSS <- function(loss_asymmetry = .5) {
  function(estimators, X, y) {
    ls_loss(estimators, X, y, loss_asymmetry)
  }
}

#' Compute quasi least absolute deviation loss
#'
#' Note that this is not a convex loss function, and so gradient descent is not guaranteed to arrive at a global minima!
#' "Qausi" because it is scaled & parametrized differently from true LAD loss. at loss_asymmetry = .5, minima are achieved at same locations as true LAD loss
#'
#' @param estimators coefficient estimators
#' @param X the data on which to evaluate loss
#' @param y the responses corresponding to y
#' @param loss_asymmetry the assymetry in [0,1] attached to under/over predictions. Closer to 0, underpredictions are penalized; Closer to 1, overpredictions are penalized.
#'
#' @author kholub
#' @examples
#' estimators <- c(1,2)
#' X <- matrix(c(1,2,3,4), nrow = 2)
#' y <- c(6, 11)
#' lad_loss(estimators, X, y)
#'
#' @export lad_loss
lad_loss <- function(estimators, X, y, loss_asymmetry = .5) {
  stopifnot(loss_asymmetry <= 1 && loss_asymmetry >= 0)

  predictions <- X %*% estimators
  errors <- y - predictions
  loss_scaling <- abs(loss_asymmetry - as.integer(errors < 0))
  mean(loss_scaling * abs(errors))
}

sigmoid <- function(x){
  1 / (1 + exp(-x))
}

#' Parameterize a quasi least absolute deviation loss function
#'
#' A convinience to create a function delegating to lad_loss
#'
#' @param loss_asymmetry parameter passed to lad_loss
#'
#' @export LAD_LOSS
LAD_LOSS <- function(loss_asymmetry = .5) {
  function(estimators, X, y) {
    lad_loss(estimators, X, y, loss_asymmetry)
  }
}

#' Compute qausi logistic loss function
#'
#' "Qausi" because it is scaled & parametrized differently from logistic loss. At loss_asymmetry = .5, achieves its minima at the same location as logistic loss.
#'
#' @param estimators coefficient estimators
#' @param X the data on which to evaluate loss
#' @param y the responses corresponding to y
#' @param loss_asymmetry the assymmetry in [0,1] of cost for misclassification. at 0, only misclassifications of the positive (1) class are considered; at 1, only misclassification of the negative (0) class are considered
#'
#' @author kholub
#' @examples
#' estimators <- c(-1,1)
#' X <- matrix(c(1,2,1.5,2.5), nrow = 2)
#' y <- c(1, 0)
#' logistic_loss(estimators, X, y)
#'
#' @export logistic_loss
logistic_loss <- function(estimators, X, y, loss_asymmetry = .5){
  predictions <- sigmoid(X %*% estimators)
  mean(loss_asymmetry * -y * log(predictions) -
         (1 - loss_asymmetry) * (1 - y) * log(1 - predictions))
}

#' Parameterize a quasi logistic loss function
#'
#' A convinience to create a function delegating to logistic_loss
#'
#' @param loss_asymmetry parameter passed to logistic_loss
#'
#' @export LOGISTIC_LOSS
LOGISTIC_LOSS <- function(loss_asymmetry = .5) {
  function(estimators, X, y) {
    logistic_loss(estimators, X, y, loss_asymmetry)
  }
}


#' Compose an existing loss function with regularization
#'
#' Given an arbitrary loss function, compose it with elastic net regularization
#'
#' @param loss the loss function to be built on
#' @param elastic_net_parameter the weighting of L1 regularization in the elastic net. L2 will be weighted as 1 - elastic_net_parameter
#' @param lambda parameter controlling how much regularization contributes to the overall loss
#'
#' @author kholub
#' @examples
#' lasso_ls <- compose_regularization(LS_LOSS, 1, 1e-5)
#' ridge_ls <- compose_regularization(LS_LOSS, 0, 1e-5)
#'
#' @export compose_regularization
compose_regularization <- function(loss, elastic_net_parameter, lambda){
  function(estimators, X, y) {
    ridge_penalty <- sum(estimators ^ 2)
    lasso_penalty <- sum(abs(estimators))
    residual_loss <- loss(estimators, X, y)

    residual_loss + lambda * (elastic_net_parameter * lasso_penalty + (1 - elastic_net_parameter) * ridge_penalty)
  }
}

