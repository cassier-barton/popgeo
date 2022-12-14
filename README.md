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
The code in this packaged is licensed under the MIT license. Datasets provided or retrieved using this package are subject to their own licensing conditions. All datasets are licensed under either the Open Government License or Open Parliament License - please look at sources for details.
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
These functions retrieve lookup tables between different types of UK geographies.

These functions **will not necessarily retrieve the most up-to-date lookups available**. ONS Open Geography often publish lookups as Excel files some time before making them available via their API (for example, 2021 ward lookups are available for Excel download but not on the API at time of publication).

The functions retrieve data for the latest year available on the API at time of publication (August 2022). However, if ONS Open Geography release new or revised boundaries after this date, the functions won't necessarily successfully retrieve them. Check the [ONS Open Geography portal](https://geoportal.statistics.gov.uk/) if you're unsure what the latest available data is.

MSOA names:
 - `get_msoanames` retrieves the latest [MSOA Names dataset](https://houseofcommonslibrary.github.io/msoanames/) from the Commons Library. The dataframe contains, for each 2011 MSOA in England and Wales, the ONS name and code, the Commons Library name, and the local authority that the MSOA is in.

The below functions retrieve data from the ONS Geoportal API. All require you to specify a year:
 - `get_la2re` returns a local authority to English region lookup
 - `get_la2n` returns a local authority to UK nation lookup
 - `get_la2rn` returns a combined lookup showing the English region or UK devolved nation a local authority is in
 - `get_ward2la` returns a ward to local authority lookup for a single specified local authority
 - `get_ward2con` returns a best-fit ward to constituency lookup for a single specified parliamentary constituency
 - `get_oa2ward` returns a 2011 Output Area to ward lookup for a given list of wards
 - `get_oa2bua` returns a 2011 Output Area to Built Up Area lookup for a given list of Built Up Areas
 - `get_oa2buasd` returns a 2011 Output Area to Built Up Area Subdivision lookup for a given list of Built Up Area Subdivisions

The below are static datasets included in the package. They aren't functions, but you can assign them to objects (e.g. `my_lookup <- con2rn`):
 - `con2rn` is a constituency to English region or UK devolved nation lookup
 - `la_changes` is a lookup showing local authority mergers from 2019 onwards
