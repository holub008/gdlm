library(gdlm)
library(ggplot2)

data(mpg)

(p1 <- ggplot(mpg) + geom_point(aes(hwy, cty)))

m <- gdlm(cty ~ hwy, mpg, loss = LS_LOSS())

summary(m)

(p2 <- p1 + geom_abline(aes(intercept = m$estimators[1], 
                            slope = m$estimators[2]), color = 'black'))



m_negative_penalty <- gdlm(cty ~ hwy, mpg, loss = LS_LOSS(.1))

summary(m_negative_penalty)

p2 + geom_abline(aes(intercept = m_negative_penalty$estimators[1], 
                     slope = m_negative_penalty$estimators[2]), color ='red')



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
                     