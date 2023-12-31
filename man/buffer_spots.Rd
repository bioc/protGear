% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/buffer_spot_functions.R
\name{buffer_spots}
\alias{buffer_spots}
\title{Extract buffer spots of data}
\usage{
buffer_spots(Data1, buffer_spot = "buffer")
}
\arguments{
\item{Data1}{An object of the class data frame}

\item{buffer_spot}{A character string containing the name of the buffer
spots.}
}
\value{
A data frame of the buffer control spots
}
\description{
A function to extract the buffer spots data. A buffer spot only
 has the solution for
 proprietary ingredients for stabilizing protein and minimizing evaporation.
}
\examples{
bg_correct_df <- readr::read_csv(system.file("extdata", "Data1_sample.csv",
package="protGear"))
buffer_spots(Data1 = bg_correct_df)
}
