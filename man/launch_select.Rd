% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/launch_protGear_interactive.R
\name{launch_select}
\alias{launch_select}
\title{launch_select}
\usage{
launch_select(theApp)
}
\arguments{
\item{theApp}{accepts one of the folders containing the shiny appplication}
}
\value{
launches the app defined under theApp
}
\description{
This is Function is to launch mutiple shiny applications for protGear
}
\examples{
validExamples <-
 list.files(system.file("shiny-examples", package = "protGear"))
#launch_select(validExamples[[1]])
}
