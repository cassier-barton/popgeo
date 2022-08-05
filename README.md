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
## Functions for downloading data from the Nomis API
### Population by age functions
These functions retrieve mid-year population estimates. Depending on the geographies you request data for, they will either retrieve data from the local authority based estimates (which are UK-wide) or the ONS' small area based estimates (for England and Wales only).

Note that once 2021 Census data is published, these estimates will not necessarily be the most recent or accurate population figures for your geographical areas of interest.

 - `pop_total` retrieves the mid-year population estimates for a given set of geographies. It takes the arguments `geog` (for a list of geographies), `sex` (for either the male, female, or total population) and `year` (for the reference year).
 - `pop_deciles` retrieves the mid-year population estimates in ten-year age bands (0-9, 10-19, etc.) As well as `sex` and `year` arguments, you can specify the `output` as either number of people ("n") or percent of population ("p").
 - `pop_range` retrieves the mid-year population estimates for an age range. Additional arguments let you specify the `lower` and `upper` bounds.
 - `get_age`is the generic function underpinning the above functions - you can specify `geog`, `sex`, `year` and `output` and receive raw data on population estimates by single year of age.
### 2011 Census functions
These functions help you retrieve certain types of data from the 2011 Census.

The below generic functions help you retrieve data for specified census tables:
 - `find_censustable` returns the Nomis database ID of a 2011 Census based on its `title` as used by the ONS (e.g. "KS201EW"). This makes it easier to use `nomisr`'s `nomis_get_data` function to retrieve census data, as well as the two functions below.
 - `census_menu` is a dataset listing single-variable 2011 Census tables which might work well with the below functions.
 - `get_c11_uk` returns data for **some** 2011 Census 'Key Statistics' tables. It only works for single-variable tables, and isn't guaranteed to work for all of them. This function is for UK tables, rather than England and Wales tables.
 - `get_c11_ew` as above, but for England and Wales tables.

The below specific functions return tidy data for a small number of specific, frequently-used census tables:
 - `c11_ethgrps_uk` retrieves data on population by ethnic group, using the broad ethnic group classifications that the ONS uses for geographic areas across the UK.
 - `c11_ethgrps_ew` retrieves data on population by ethnic group, using the (slightly more detailed) broad ethnic group classifications that the ONS uses for geographic areas across England and Wales only.
 - `c11_ethdetail_ew` retrieves data on population by ethnic group, using the ONS' "detailed" ethnic group classification. England and Wales only.
 - `c11_tenure_uk` retrieves data on housing tenure (home ownership, private/social renting) for UK geographical areas.
 - `c11_cob_uk` retrieves data on country of birth for UK geographical areas and summarises into broad categories (UK, Ireland, Other EU, Rest of Europe, Rest of World).
### Warning: functions do not work for certain types of geographical area
These functions will return data for most UK geographies for which data is available, with some exceptions. The Nomis API won't return data for Built Up Areas, Built Up Area Subdivisions, "Major Towns and Cities", wards, CCGs, or health boards. This appears to be an issue with how it recognises ONS codes.

If you need data for Built Up Areas, Built Up Area Subdivisions, wards, or major towns and cities, then the functions below can provide you with a lookup that will help you construct your own totals from Output Areas.

## Functions to get lookups for UK geographies

MSOA names:

