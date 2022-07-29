#' Key: type and extent of geography referred to by ONS 9-digit entity codes
#'
#' A dataset with information for each type of ONS 9-digit entity code (e.g. E01),
#' showing the type of geographic area it refers to (e.g. LSOA) and its coverage.
#'
#' @format A data frame with 184 observations and 4 variables.
#' \describe{
#' \item{ent_code}{first three digits of the entity code}
#' \item{ent_name}{the name of the geography type the code refers to}
#' \item{ent_type}{the broader category the geography type sits within}
#' \item{ent_coverage}{the geographic coverage of the geography type}
#' }
#'
#'
#' @source ONS

"geo_types"



#' A dataframe showing a constituency to region/nation lookup
#'
#' A dataframe showing the name and ONS 9-digit code of each constituency in
#' the UK, along with the name and 9-digit code of the English region the
#' constituency is in (if in England) or the nation (if it's in a devolved
#' nation).
#'
#' @format A data frame with 650 observations and 4 variables.
#' \describe{
#' \item{con_code}{9-digit ONS code of the constituency}
#' \item{con_name}{the name of the constituency}
#' \item{rn_code}{the 9-digit ONS code of the region/nation the constituency is in}
#' \item{rn_name}{the name of the region/nation the constituency is in}
#' }
#'
#'
#' @source ONS

"con2rn"

#' A dataframe showing district-level local authority changes in England (2019-2021)
#'
#' A dataframe showing which former district local authorities were combined to
#' create new district local authorities in 2019, 2020, and 2021. Also shows
#' which region each of these local authorities are in.
#'
#' @format A data frame with 25 observations and 7 variables.
#' \describe{
#' \item{oa_code}{9-digit ONS code of a 2011 Census Output Area}
#' \item{con_code}{9-digit ONS code of the UK parliamentary constituency the Output Area best-fits to}
#' \item{con_name}{name of the UK parliamentary constituency the Output Area best-fits to}
#' }
#'
#' @source Commons Library analysis of ONS Open Geography datasets

"la_changes"


