#' Get a dataframe with the latest Commons Library MSOA names
#'
#' Returns a dataframe that shows, for each 2011 MSOA in England and Wales, the ONS
#' name and code for the MSOA, the Commons Library name, and the local authority
#' that the MSOA is in.
#'
#' @return A dataframe with ONS 9-digit code, ONS name in English and Welsh, Commons Library name in English and Welsh (Welsh MSOAs only), and LA name.
#'
#' @examples
#' get_msoanames()
#'
#' @export

get_msoanames <- function () {

  readr::read_csv("https://houseofcommonslibrary.github.io/msoanames/MSOA-Names-Latest.csv") %>%
    janitor::clean_names()

}



#' Get a local authority to region table for England, for a given year.
#'
#' Returns a dataframe that shows names and ONS 9-digit codes for all local
#' authorities in England, plus names and codes for the region each local
#' authority is in. At time of writing, tables are available for years 2018
#' through to 2021. Data is retrieved from ONS Geoportal. Local authorities
#' are generally as at April for your specified year if there has been a
#' boundary change, or December if there hasn't, but it's worth checking the
#' Geoportal website to be sure.
#'
#'
#' @param year A number for the desired year, in format YYYY
#'
#' @return A dataframe with names/codes for LAs, and names/codes for associated regions.
#'
#' @examples
#' get_la2re(2018)
#'
#' @export

get_la2re <- function(year) {

  yr <- stringr::str_sub(year, 3)

  path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD",
                yr,
                "_RGN",
                yr,
                "_EN_LU/FeatureServer/0/query")

  json <- httr::GET(path,
              query = list(where = "1=1",
                           outFields = "*",
                           returnGeometry = "false",
                           outSR = "4326",
                           f = "json"))

  df <-  jsonlite::fromJSON(rawToChar(json$content))

  out <- df$features$attributes %>%
    dplyr::select(c(1:4))

}

#' Get a local authority to nation table for the UK, for a given year.
#'
#' Returns a dataframe that shows names and ONS 9-digit codes for all local
#' authorities in England, plus names and codes for the region each local
#' authority is in. At time of writing, tables are available for years 2015
#' through to 2021. Data is retrieved from ONS Geoportal. Local authorities
#' are generally as at April for your specified year if there has been a
#' boundary change, or December if there hasn't, but it's worth checking the
#' Geoportal website to be sure.
#'
#' @param year A number for the desired year, in format YYYY
#'
#' @return A dataframe with names/codes for LAs, and names/codes for associated countries
#'
#' @examples
#' df <- get_la2n(2018)
#'
#' @export

get_la2n <- function(year) {

  yr <- stringr::str_sub(year, 3)

  path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD",
                         yr,
                         "_CTRY",
                         yr,
                         "_UK_LU/FeatureServer/0/query")

  json <- httr::GET(path,
                    query = list(where = "1=1",
                                 outFields = "*",
                                 returnGeometry = "false",
                                 outSR = "4326",
                                 f = "json"))

  df <-  jsonlite::fromJSON(rawToChar(json$content))

  out <- df$features$attributes %>%
    dplyr::select(c(1:4))
}


#' Get a local authority to region/nation table for the UK, for a given year
#'
#' Returns a dataframe that shows names and ONS 9-digit codes for all local
#' authorities in the UK, plus names and codes for the English region or
#' deveolved nation each local authority is in. At time of writing, tables are
#' available for years 2018 through to 2021. Data is retrieved from ONS Geoportal.
#' Local authorities are generally as at April for your specified year if there
#' has been a boundary change, or December if there hasn't, but it's worth
#' checking the Geoportal website to be sure.
#'
#' @param year A number for the desired year, in format YYYY
#'
#' @return A dataframe with names/codes for LAs, and names/codes for associated regions/nations.
#'
#' @examples
#' get_la2rn(2018)
#'
#' @export


get_la2rn <- function(year) {

  england <- get_la2re(year) %>%
    dplyr::rename(la_code = 1,
                  la_name = 2,
                  rn_code = 3,
                  rn_name = 4)

  restuk <- get_la2n(year) %>%
    dplyr::rename(la_code = 1,
                  la_name = 2,
                  rn_code = 3,
                  rn_name = 4)

  restuk <- dplyr::filter(restuk, rn_name != "England")

  out <- rbind(england, restuk)

}

#' Get a ward to local authority lookup (search by single local authority)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing a ward to local authority
#' lookup for a specified UK local authority and year.
#'
#' At time of writing, data is available through the API for 2016 through to 2020.
#' 2021 data is published on the ONS Geoportal website, but not yet available
#' via the API.
#'
#' @param la A string specifying the 9-digit ONS code for your chosen local authority
#' @param year A number for the desired year, in format YYYY
#'
#' @return A dataframe with names/codes for wards, and the names/codes for associated local authorities for each one.
#'
#' @examples
#' get_ward2la(la = "E09000001", year = 2019)
#'
#' @export

get_ward2la <- function(la, year) {

  yr <- stringr::str_sub(year, 3)

  if (year == 2020) {

    path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/WD",
                           yr,
                           "_LAD",
                           yr,
                           "_UK_LU_v2/FeatureServer/0/query")

  } else {

    path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/WD",
                           yr,
                           "_LAD",
                           yr,
                           "_UK_LU/FeatureServer/0/query")
  }

  json <- httr::GET(path,
                    query = list(where = stringr::str_c("LAD", yr, "CD = '", la, "'"),
                                 outFields = "*",
                                 returnGeometry = "false",
                                 outSR = "4326",
                                 f = "json"))

  df <-  jsonlite::fromJSON(rawToChar(json$content))

  cols <- c(stringr::str_c("WD", yr, "CD"),
            stringr::str_c("WD", yr, "NM"),
            stringr::str_c("LAD", yr, "CD"),
            stringr::str_c("LAD", yr, "NM"))

  out <- df$features$attributes %>%
    dplyr::select(dplyr::any_of(cols))

}

#' Get a ward to parliamentary constituency lookup (search by single constituency)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing a ward to constituency
#' lookup for a specified UK parliamentary constituency and year.
#'
#' At time of writing, data is available through the API for 2016 through to 2020.
#' 2021 data is published on the ONS Geoportal website, but not yet available
#' via the API.
#'
#' @param con A string specifying the 9-digit ONS code for your chosen constituency
#' @param year A number for the desired year, in format YYYY
#'
#' @return A dataframe with names/codes for wards, and the names/codes for associated local authorities for each one.
#'
#' @examples
#' get_ward2con(la = "E14000639", year = 2019)
#'
#' @export

get_ward2con <- function(con, year) {

  yr <- stringr::str_sub(year, 3)

  if (year == 2020) {

    path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/WD",
                           yr,
                           "_PCON",
                           yr,
                           "_LAD",
                           yr,
                           "_UK_LU_v2/FeatureServer/0/query")

  } else {

    path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/WD",
                           yr,
                           "_PCON",
                           yr,
                           "_LAD",
                           yr,
                           "_UK_LU/FeatureServer/0/query")

  }

  json <- httr::GET(path,
                    query = list(where = stringr::str_c("PCON", yr, "CD = '", con, "'"),
                                 outFields = "*",
                                 returnGeometry = "false",
                                 outSR = "4326",
                                 f = "json"))

  df <-  jsonlite::fromJSON(rawToChar(json$content))

  cols <- c(stringr::str_c("WD", yr, "CD"),
            stringr::str_c("WD", yr, "NM"),
            stringr::str_c("PCON", yr, "CD"),
            stringr::str_c("PCON", yr, "NM"))

  out <- df$features$attributes %>%
    dplyr::select(dplyr::any_of(cols))

}

#' Get an output area to ward and local authority lookup (search by single ward)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing an Output Area to
#' ward to local authority lookup for a specified ward and year. This function
#' feeds into the more useful get_oa2ward function, which lets you retrieve
#' data for multiple wards at once.
#'
#' Output areas are matched to wards on a best-fit basis. England and Wales only.
#'
#' @param ward A string specifying the 9-digit ONS code for a single ward
#' @param year A number for the desired year, in format YYYY
#'
#' @return A dataframe with names/codes for output areas, and the names/codes of the associated ward and local authority.
#'
#' @examples
#' get_oa2ward_single(ward = "E05010317", year = 2019)
#'
#' @export

get_oa2ward_single <- function(ward, year) {

  yr <- stringr::str_sub(year, 3)

  if (year == 2018) {

    path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/OA11_WD",
                           yr,
                           "_LAD",
                           yr,
                           "_EW_LUv2/FeatureServer/0/query")

  } else if (year == 2020) {

    path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/OA11_WD",
                           yr,
                           "_LAD",
                           yr,
                           "_EW_LU_v2/FeatureServer/0/query")

  } else {

    path <- stringr::str_c("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/OA11_WD",
                           yr,
                           "_LAD",
                           yr,
                           "_EW_LU/FeatureServer/0/query")
  }

  json <- httr::GET(path,
                   query = list(where = stringr::str_c("WD", yr, "CD = '", ward, "'"),
                                outFields = "*",
                                returnGeometry = "false",
                                outSR = "4326",
                                f = "json"))

  df <-  jsonlite::fromJSON(rawToChar(json$content))

  out <- df$features$attributes %>%
    dplyr::select(c(1,2,3,5,6))
}


#' Get an output area to ward and local authority lookup (search by multiple wards)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing an output area to
#' ward to local authority lookup for a specified set of wards and a year. The
#' lookup for all Output Areas is too large to return in one go, which is why
#' this function asks you to search by ward.
#'
#' Output areas are matched to wards on a best-fit basis. England and Wales only.
#'
#' @param wards A string, or a vector of strings, specifying the 9-digit ONS code for your chosen ward(s)
#' @param year A number for the desired year, in format YYYY
#'
#' @return A dataframe with names/codes for output areas, and the names/codes of associated wards and local authorities for each one.
#'
#' @examples
#' get_oa2ward(ward = c("E05010317", "E05010319", "E05010326"), year = 2019)
#'
#' @export

get_oa2ward <- function(wards, year) {

  df <- tibble::tibble(ward = wards, year = year)

  out <- purrr::map2_dfr(df$ward, df$year, get_oa2ward_single)

}

#' Get an output area to Built Up Area lookup (search by single Built Up Area)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing an Output Area to
#' Built Up Area lookup for a specified Built Up Area (2011) and year. This function
#' feeds into the more useful get_bua2ward function, which lets you retrieve
#' data for multiple Built Up Areas at once.
#'
#' England and Wales only.
#'
#' @param bua A string specifying the 9-digit ONS code for a single Built Up Area
#'
#' @return A dataframe with names/codes for output areas, and the names/codes of the associated Built Up Area
#'
#' @examples
#' get_oa2bua_single(bua = "E34004922")
#'
#' @export

get_oa2bua_single <- function(bua) {

  path <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/OA11_BUASD11_BUA11_LAD11_RGN11_EW_LU/FeatureServer/0/query"

  json <- httr::GET(path,
                    query = list(where = stringr::str_c("BUA11CD = '", bua, "'"),
                                 outFields = "OA11CD,BUA11CD,BUA11NM",
                                 returnGeometry = "false",
                                 outSR = "4326",
                                 f = "json"))

  df <-  jsonlite::fromJSON(rawToChar(json$content))

  out <- df$features$attributes %>%
    dplyr::select(c(1:3))
}

#' Get an output area to Built Up Area lookup (search by multiple Built Up Areas)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing an output area to
#' Built Up Area lookup for a specified set of Built Up Areas (2011). The
#' lookup for all Output Areas is too large to return in one go, which is why
#' this function asks you to search by Built Up Area.
#'
#' England and Wales only.
#'
#' @param buas A string, or a vector of strings, specifying the 9-digit ONS code for your chosen Built Up Area(s)
#'
#' @return A dataframe with names/codes for output areas, and the names/codes of associated Built Up Areas for each one.
#'
#' @examples
#' get_oa2bua(buas = c("E34001405", "E34002311", "E34000732"))
#'
#' @export

get_oa2bua <- function(buas) {

  purrr::map_dfr(buas, get_oa2bua_single)

}


#' Get an output area to Built Up Area Subdivision lookup (search by single Built Up Area Subdivision)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing an Output Area to
#' Built Up Area Subdivision (BUASD) lookup for a specified BUASD (2011) and year. This function
#' feeds into the more useful get_buasd2ward function, which lets you retrieve
#' data for multiple BUASDs at once.
#'
#' England and Wales only.
#'
#' @param buasd A string specifying the 9-digit ONS code for a single Built Up Area Subdivision
#'
#' @return A dataframe with names/codes for output areas, and the names/codes of the associated Built Up Area Subdivision and Built Up Area
#'
#' @examples
#' get_oa2buasd_single(buasd = "E35001205")
#'
#' @export

get_oa2buasd_single <- function(buasd) {

  path <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/OA11_BUASD11_BUA11_LAD11_RGN11_EW_LU/FeatureServer/0/query"

  json <- httr::GET(path,
                    query = list(where = stringr::str_c("BUASD11CD = '", buasd, "'"),
                                 outFields = "OA11CD,BUASD11CD,BUASD11NM,BUA11CD,BUA11NM",
                                 returnGeometry = "false",
                                 outSR = "4326",
                                 f = "json"))

  df <-  jsonlite::fromJSON(rawToChar(json$content))

  out <- df$features$attributes %>%
    dplyr::select(c(1:5))
}

#' Get an output area to Built Up Area Subdivision lookup (search by multiple Built Up Area Subdivisions)
#'
#' Retrieves a dataframe from the ONS Geoportal API showing an output area to
#' Built Up Area Subdivision (BUASD) to Built Up Area lookup for a specified set
#' of BUASDs (2011). Thelookup for all Output Areas is too large to return in one
#' go, which is why this function asks you to search by BUASD.
#'
#' England and Wales only.
#'
#' @param buasds A string, or a vector of strings, specifying the 9-digit ONS code for your chosen Built Up Area Subdivision(s)
#'
#' @return A dataframe with names/codes for output areas, and the names/codes of associated Built Up Area Subdivisions and Built Up Areas.
#' @examples
#' get_oa2buasd(buasds = c("E35000528", "E35000500", "E35001362", "E35001381"))
#'
#' @export

get_oa2buasd <- function(buasds) {

  purrr::map_dfr(buasds, get_oa2buasd_single)

}
