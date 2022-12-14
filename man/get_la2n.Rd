% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geo_lookups.R
\name{get_la2n}
\alias{get_la2n}
\title{Get a local authority to nation table for the UK, for a given year.}
\usage{
get_la2n(year)
}
\arguments{
\item{year}{A number for the desired year, in format YYYY}
}
\value{
A dataframe with names/codes for LAs, and names/codes for associated countries
}
\description{
Returns a dataframe that shows names and ONS 9-digit codes for all local
authorities in England, plus names and codes for the region each local
authority is in. At time of writing, tables are available for years 2015
through to 2021. Data is retrieved from ONS Geoportal. Local authorities
are generally as at April for your specified year if there has been a
boundary change, or December if there hasn't, but it's worth checking the
Geoportal website to be sure.
}
\examples{
df <- get_la2n(2018)

}
