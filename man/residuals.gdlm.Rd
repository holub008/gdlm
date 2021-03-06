% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/residuals.gdlm.R
\name{residuals.gdlm}
\alias{residuals.gdlm}
\title{Produce residuals from a gradient descent generated linear model}
\usage{
\method{residuals}{gdlm}(object, type = c("working", "response"))
}
\arguments{
\item{object}{model to generate residuals for}

\item{type}{the scale on which to generate residuals}
}
\description{
Produce residuals from a gradient descent generated linear model
}
\examples{
m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS())
residuals(m)

}
\author{
kholub
}
