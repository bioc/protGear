% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/normalisation_functions.R
\name{rlm_normalise_matrix}
\alias{rlm_normalise_matrix}
\title{Nomrmalise using RLM}
\usage{
rlm_normalise_matrix(matrix_antigen, array_matrix, control_antigens)
}
\arguments{
\item{matrix_antigen}{A matrix with antigen data}

\item{array_matrix}{A matrix with control antigen data}

\item{control_antigens}{the control antigens for RLM normalisation}
}
\value{
A RLM normalised data frame
}
\description{
A function for \code{method='rlm'} from 
\code{\link{matrix_normalise}}.
}
\examples{
matrix_antigen <- readr::read_csv(system.file("extdata",
 "matrix_antigen.csv", package="protGear"))
# rlm_normalise_matrix(matrix_antigen=matrix_antigen,
 #array_matrix=array_matrix,
# control_antigens=control_antigens)
}
