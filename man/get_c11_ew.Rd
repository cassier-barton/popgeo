% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nomis_census.R
\name{get_c11_ew}
\alias{get_c11_ew}
\title{Get 2011 Census data from Nomis: England & Wales tables}
\usage{
get_c11_ew(title, geog, output = "n")
}
\arguments{
\item{title}{A string containing the ONS title of a 2011 Census table.}

\item{geog}{A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")}

\item{output}{Specify "n" for counts or "p" for percentages. Defaults to "n".}
}
\value{
A tibble with a row for each geographic area specified, and columns
    for each of the values within the demographic variable covered by the
    requested table.
}
\description{
Nomis data retreival function. Returns data for most 2011 Census 'Key
Statistics' tables if they are designated as England & Wales tables, rather
than UK tables. It only works for single-variable tables, and isn't guaranteed
to work for all of them.
}
\details{
See the census_menu dataset in this package for a list of census tables to try.
Key statistics tables for England and Wales have a 'KS' prefix and an 'EW' suffix.
}
\examples{

oxford_cars <- get_c11_ew(title = "KS404EW", geog = "E07000178")

hours_percents <- get_c11_ew(title = "KS604EW", geog = c("E06000014", "E07000121"), output = "p")

}
