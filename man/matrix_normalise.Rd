% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/normalisation_functions.R
\name{matrix_normalise}
\alias{matrix_normalise}
\title{Normalize  Arrays}
\usage{
matrix_normalise(
  matrix_antigen,
  method = "log2",
  batch_correct = FALSE,
  batch_var1,
  batch_var2 = day_batches,
  return_plot = FALSE,
  plot_by_antigen = TRUE,
  control_antigens = NULL,
  array_matrix = NULL
)
}
\arguments{
\item{matrix_antigen}{An object of class matrix with  features/proteins as 
columns and samples as the rows}

\item{method}{character string specifying the normalization method.
 Choices are \code{"none","log2","vsn","cyclic_loess"}
\code{"cyclic_loess_log" ,"rlm"}}

\item{batch_correct}{A logical value indicating whether batch
correction should be done or not}

\item{batch_var1}{A character or factor vector of size similar to rows 
of \code{matrix_antigen} indicating the first batch.}

\item{batch_var2}{A character or factor vector of size similar to rows 
of \code{matrix_antigen} indicating the second batch.}

\item{return_plot}{A logical value indicating whether a plot is returned 
to show the results of normalisation.}

\item{plot_by_antigen}{Logical to indicate whether to plot by antigen or not
slide name for the matrix_antigen object.}

\item{control_antigens}{logical vector specifying the subset of spots 
which are non-differentially-expressed control spots,
for use with \code{method="rlm"}}

\item{array_matrix}{An object of class dataframe or matrix used with
\code{method='rlm'} indicating the sample index and}
}
\value{
A data frame of normalised values
}
\description{
Normalize  Arrays
}
\examples{
matrix_antigen <- readr::read_csv(system.file("extdata", 
"matrix_antigen.csv", package="protGear"))
#VSN
normlise_vsn <- matrix_normalise(as.matrix(matrix_antigen),
method = "vsn",
return_plot = TRUE
)
## log
normlise_log <- matrix_normalise(as.matrix(matrix_antigen),
method = "log2",
return_plot = TRUE
)
## cyclic_loess_log
normlise_cylic_log <- matrix_normalise(as.matrix(matrix_antigen),
method = "cyclic_loess_log",
return_plot = TRUE
)
}
