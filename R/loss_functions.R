# todo: (imbalance of over/under predictions set to 0)
# todo: na handling
# todo: numeric instabilities for ex. log loss

#' Least squares loss function
#' 
#' @param estimators coefficient estimators
#' @param X the data on which to evaluate loss
#' @param the responses corresponding to y
#' 
#' @author kholub
#' @examples 
#' estimators <- c(1,2)
#' X <- matrix(c(1,2,3,4), nrow = 2)
#' y <- c(6, 11)
#' LS_LOSS(estimators, X, y)
#' 
#' @export LS_LOSS
LS_LOSS <- function(estimators, X, y) {
  predictions <- X %*% estimators
  mean((y-predictions)^2)
}

#' Least absolute deviation loss
#' 
#' Note that this is not a convex loss function, and so gradient descent is not guaranteed to arrive at a global minima!
#' 
#' @param estimators coefficient estimators
#' @param X the data on which to evaluate loss
#' @param the responses corresponding to y
#' 
#' @author kholub
#' @examples 
#' estimators <- c(1,2)
#' X <- matrix(c(1,2,3,4), nrow = 2)
#' y <- c(6, 11)
#' LAD_LOSS(estimators, X, y)
#' 
#' @export LAD_LOSS
LAD_LOSS <- function(estimators, X, y) {
  predictions <- X %*% estimators
  mean(abs(y-predictions))
}

sigmoid <- function(x){
  1 / (1 + exp(-x))
}

#' Logistic loss function
#'
#' @param estimators coefficient estimators
#' @param X the data on which to evaluate loss
#' @param the responses corresponding to y
#'
#' @author kholub
#' @examples 
#' estimators <- c(-1,1)
#' X <- matrix(c(1,2,1.5,2.5), nrow = 2)
#' y <- c(1, 0)
#' LOGISTIC_LOSS(estimators, X, y)
#'
#' @export LOGISTIC_LOSS
LOGISTIC_LOSS <- function(estimators, X, y){
  predictions <- sigmoid(X %*% estimators)
  mean(-y * log(predictions) - (1 - y)*log(1 - predictions))
}

# todo hinge


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

