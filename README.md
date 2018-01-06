# gdlm
Gradient Descent for Linear Models in R

Perform gradient descent to build linear models and use bootstrapping to generate standard errors on estimators. Motivation for this project is that in practice, loss functions for regressions are rarely symmetric, yet most prevalent regression tools in R assume symmetry with no configurability otherwise. Goal is to provide flexibility in loss function specification combined with general ease of use associated with other linear models in R.
## Installation
```R
devtools::install_git('https://github.com/holub008/gdlm')
```

## Examples
### Asymmetric loss for least squares
Here we fit an OLS model predicting city mpg from highway mpg on the mpg dataset from ggplot:
```R
data(mpg)
(p1 <- ggplot(mpg) + geom_point(aes(hwy, cty)))

m <- gdlm(cty ~ hwy, mpg, loss = LS_LOSS())
summary(m)
(p2 <- p1 + geom_abline(aes(intercept = m$estimators[1],
                            slope = m$estimators[2]), color = 'black'))
```
with results:
```
[1] "Formula: cty ~ hwy"
[1] "Esimators:"
             Estimate Standard Error        5%       95%
(Intercept) 0.8416769      0.3737633 0.2760343 1.4903538
hwy         0.6832955      0.0164563 0.6570886 0.7089135
```
![mpg_ls_fit](docs/images/mpg_ls_fit.png)

If we have a prediction problem where overpredictions are more heavily penalized than underpredictions, we parameterize our loss function as:
```R
m_negative_penalty <- gdlm(cty ~ hwy, mpg, loss = LS_LOSS(loss_asymmetry = .1))

p2 + geom_abline(aes(intercept = m_negative_penalty$estimators[1],
                     slope = m_negative_penalty$estimators[2]), color ='red')
```
![mpg_underpred_fit](docs/images/mpg_ls_underpred_fit.png)

In practice the loss asymmetry would likely be determined through a cross validation. Note that loss asymmetry can similarly be applied to LAD/logistic loss functions:

```R
m_lad <- gdlm(cty ~ hwy, mpg, loss = LAD_LOSS())
m_lad_negative_penalty <- gdlm(cty ~ hwy, mpg, loss = LAD_LOSS(loss_asymmetry = .1))
p1 +
  geom_abline(aes(intercept = m_lad$estimators[1], slope = m_lad$estimators[2]), color = 'blue') +
  geom_abline(aes(intercept = m_lad_negative_penalty$estimators[1],
                     slope = m_lad_negative_penalty$estimators[2]), color ='red') + ggtitle('Least Absolute Deviation Fits')
```
![mpg_lad_fits](docs/images/lad_fits.png)

Note that the LAD case is quite similar to quantile regression.

### Elastic net regularized logistic regression
```R
car_data <- mpg
car_data$is_big_car <- mpg$class %in% c('suv', 'pickup', 'minivan')

m_log <- gdlm(is_big_car ~ hwy, car_data, loss = LOGISTIC_LOSS())
summary(m_log)

log_odds <- predict(m_log)
ggplot() + geom_histogram(aes(log_odds, fill = car_data$is_big_car))

m_log_shrunk <- gdlm(is_big_car ~ hwy, car_data,
                     loss = compose_regularization(LOGISTIC_LOSS(), elastic_net_parameter = .5, lambda = 1e-3))
summary(m_log_shrunk)

log_odds <- predict(m_log_shrunk)
ggplot() + geom_histogram(aes(log_odds, fill = car_data$is_big_car))
```

### Parallelization
If computing bootstrapped SEs with many trials, one may benefit by increasing the level of parallelism:

```R
options(mc.cores = 1)
system.time(m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS(), 
            bootstrap_trials = 1e4))
     user  system elapsed 
  145.614   6.377 152.595 
  
options(mc.cores = 4)
system.time(m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS(), 
                      bootstrap_trials = 1e4))
     user  system elapsed 
   92.386   4.420  47.913 

```
Note this will only work on Unix variants.
