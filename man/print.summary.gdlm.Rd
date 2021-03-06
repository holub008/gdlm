% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.gdlm.R
\name{print.summary.gdlm}
\alias{print.summary.gdlm}
\title{Print a gdlm summary}
\usage{
\method{print}{summary.gdlm}(object, ...)
}
\arguments{
\item{object}{the summary.gdlm object to be printed}
}
\description{
Print a gdlm summary
}
\examples{
m <- gdlm(Sepal.Width ~ Species * Petal.Width + Petal.Length, data = iris, loss = LS_LOSS())
print(summary(m))

}
\author{
kholub
}
