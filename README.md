# gdlm
Gradient Descent for Linear Models in R

Perform gradient descent to build linear models and use bootstrapping to generate standard errors on estimators. Motivation for this project is that in practice, loss functions for regressions are rarely symmetric, yet most prevalent regression tools in R assume symmetry with no configurability otherwise. Goal is to provide flexibility in loss function specification combined with general ease of use associated with other linear models in R.
## Installation
```
devtools::install_git('https://github.com/holub008/gdlm')
```
