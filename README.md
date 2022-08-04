# popgeo
This package provides some basic functions to retrieve population estimates and 2011 Census data from Nomis, as well as a series of lookups for matching different types of geographical areas in the UK. It was developed to help statisticians working with data at the House of Commons Library.

This package is in development and I welcome feedback. You should check data against external sources when using it for research.
## Overview
`popgeo` brings together two collections of functions for working with population and other data for geographical areas within the UK.

One set of functions helps you query the [Office for National Statistics' Nomis API](https://www.nomisweb.co.uk/api/v01/help) for population data, using the [`nomisr` package developed by Evan Odell](https://github.com/ropensci/nomisr). There are functions for retrieving data on the population broken down by age, as well as general and specific functions for retrieving 2011 Census data. All functions will return data for a list of geographical areas.

The other set of functions return lookup tables between different types of geographical area in the UK (e.g. between parliamentary constituencies and nations/regions). Some of the functions retrieve data directly from the [ONS' Geoportal API](https://www.api.gov.uk/ons/open-geography-portal/#open-geography-portal).
### A note on geography codes
All of the functions in this package ask you to provide ONS geography codes when specifying the geographical areas you want data for. These are nine-digit codes that the ONS uses as unique identifiers for geographical areas, such as E09000028 for the London Borough of Southwark. These codes are commonly used in government statistics and geographical products, including boundary datasets.

You can find lists of geography codes on the [ONS Open Geography Portal website.](https://geoportal.statistics.gov.uk/)

## Licensing
!!!Don't forget to add this bit!!!
## Installation
Install from Github using remotes.
```
install.packages("remotes")
remotes::install_github("cassier-barton/popgeo")
```
## Download data from the Nomis API
### Population by age functions
### 2011 Census functions
### Functions do not work for certain types of geographical area
## Get lookups for UK geographies
