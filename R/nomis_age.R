#' Retrieve population by age data from Nomis
#'
#' Returns raw population by age data from Nomis for specified sex(es),
#' geography(ies) and year. Determines automatically whether data should
#' be retrieved from the small-area-based estimates or the local-authority-
#' based estimates.
#'
#' Local-authority based estimates (for LAs and any larger geographies) are
#' available from 1991 across the UK. Small-area based estimates (for any
#' geography smaller than an LA) are available from 2011 for England and Wales.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param sex Specify "m" for male, "f" for female, or "t" for total. Defaults to "t".
#' @param year An integer specifying the year for which data is needed, or use the string "latest" for the most recent year available. Defaults to "latest".
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with all available age data from Nomis.
#'
#' @examples
#' oxford_raw <- get_age(geog = "E07000178")
#'
#' @export

get_age <- function (geog, sex = "t", year = "latest", output = "n") {

  output <- dplyr::case_when(output == "n" ~ "Value",
                      output == "p" ~ "Percent")

  sex <- dplyr::case_when(sex == "m" ~ 1,
                   sex == "f" ~ 2,
                   sex == "t" ~ 0)

  typed <- tibble::tibble(ons_code = geog) %>%
    dplyr::mutate(ent_code = stringr::str_sub(ons_code, 1, 3)) %>%
    dplyr::inner_join(pop_key, by = c("ent_code")) %>%
    dplyr::select(ons_code, nomis_source)

  sab_areas <- typed %>%
    dplyr::filter(nomis_source == "sa_based")

  lab_areas <- typed %>%
    dplyr::filter(nomis_source == "la_based")

  if (nrow(sab_areas) == 0) {

    sab_stats <- NULL

  } else {

    sab_stats <- nomisr::nomis_get_data(id = "NM_2010_1",
                                date = year,
                                sex = sex,
                                geography = sab_areas$ons_code,
                                tidy = TRUE,
                                select = c("geography_code",
                                           "geography_name",
                                           "date",
                                           "c_age_type",
                                           "c_age_name",
                                           "c_age_code",
                                           "measures_name",
                                           "obs_value")) %>%
      dplyr::filter(measures_name == output)
  }

  if (nrow(lab_areas) == 0) {

    lab_stats = NULL

  } else {

    lab_stats <- nomisr::nomis_get_data(id = "NM_2002_1",
                                date = year,
                                sex = sex,
                                geography = lab_areas$ons_code,
                                tidy = TRUE,
                                select = c("geography_code",
                                           "geography_name",
                                           "date",
                                           "c_age_type",
                                           "c_age_name",
                                           "c_age_code",
                                           "measures_name",
                                           "obs_value")) %>%
      dplyr::filter(measures_name == output)

  }

  if (is.null(sab_stats)) {

    df <- lab_stats

  } else if (is.null(lab_stats)) {

    df <- sab_stats

  } else {

    df <- rbind(sab_stats, lab_stats) }

}

#' Retrieve total population for a given area from Nomis
#'
#' Returns the total population for a given set of geographies with sex
#' and year speified. Automatically retrieves data from small-area-based
#' and/or local-authority-based estimates as appropriate.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param sex Specify "m" for male, "f" for female, or "t" for total. Defaults to "t".
#' @param year An integer specifying the year for which data is needed, or use the string "latest" for the most recent year available. Defaults to "latest".
#'
#' @return A tibble with a row for each geography selected and columns showing the year and total population.
#'
#' @examples
#' oxford_total <- pop_total(geog = "E07000178")
#'
#' oxford_women <- pop_total(geog = "E07000178", sex = "f", year = 2019)
#'
#' @export

pop_total <- function (geog, sex = "t", year = "latest")

{
  get_age(geog = geog, sex = sex, year = year, output = "n") %>%
    dplyr::filter(c_age_name == "All Ages",
           c_age_type == "Individual age") %>%
    dplyr::select(geography_code, geography_name, date, obs_value)
}


#' Retrieve population deciles for a given area from Nomis
#'
#' Returns the population in ten-year age bands for a given set of geographies
#' with sex and year speified. Automatically retrieves data from
#' small-area-based and/or local-authority-based estimates as appropriate.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param sex Specify "m" for male, "f" for female, or "t" for total. Defaults to "t".
#' @param year An integer specifying the year for which data is needed, or use the string "latest" for the most recent year available. Defaults to "latest".
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geography specified and columns for the year and each age band.
#'
#' @examples
#'
#' oxford_deciles <- pop_deciles(geog = "E07000178")
#'
#' oxford_men_percent <- pop_deciles(geog = "E07000178", sex = "m", output = "p")
#'
#' @export

pop_deciles <- function(geog, sex = "t", year = "latest", output = "n")

{

  get_age(geog = geog, sex = sex, year = year, output = output)  %>%
    dplyr::filter(c_age_type == "5 year age band") %>%
    dplyr::select(-c_age_code) %>%
    dplyr::distinct() %>%
    tidyr::pivot_wider(names_from = c_age_name, values_from = obs_value) %>%
    janitor::clean_names() %>%
    dplyr::transmute(geography_code = geography_code,
              geography_name = geography_name,
              date = date,
              aged_0_9 = age_0_4 + aged_5_9,
              aged_10_19 = aged_10_14 + aged_15_19,
              aged_20_29 = aged_20_24 + aged_25_29,
              aged_30_39 = aged_30_34 + aged_35_39,
              aged_40_49 = aged_40_44 + aged_45_49,
              aged_50_59 = aged_50_54 + aged_55_59,
              aged_60_69 = aged_60_64 + aged_65_69,
              aged_70_79 = aged_70_74 + aged_75_79,
              aged_80_plus = aged_80_84 + aged_85)


}

#' Retrieve population within a specified age range for a given area from Nomis
#'
#' Returns the population for a given age range and a given set of geographies
#' with sex and year speified. Automatically retrieves data from
#' small-area-based and/or local-authority-based estimates as appropriate.
#' Note that in this dataset, the integer '90' stands in for all ages from 90
#' upwards.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param sex Specify "m" for male, "f" for female, or "t" for total. Defaults to "t".
#' @param year An integer specifying the year for which data is needed, or use the string "latest" for the most recent year available. Defaults to "latest".
#' @param lower An integer specifying the lower bound of the age range. Defaults to 0.
#' @param upper An integer specifying the upper bound of the age range. Defaults to 90 (the integer for all ages 90 and above).
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geography specified.
#'
#' @examples
#'
#' oxford_children_f <- pop_range(geog = "E07000178", sex = "f", lower = 0, upper = 17)
#'
#' oxford_60_plus_pc <- pop_range(geog = "E07000178", lower = 60)
#'
#' @export

pop_range <- function(geog, sex = "t", year = "latest", lower = 0, upper = 90, output = "n")

{
  get_age(geog = geog, sex = sex, year = year, output = output)  %>%
    dplyr::filter(c_age_type == "Individual age",
           c_age_name != "All Ages") %>%
    dplyr::mutate(age_code = as.numeric(c_age_code),
           age = age_code - 101) %>%
    dplyr::select(geography_code, geography_name, date, age, obs_value) %>%
    dplyr::filter (age >= lower,
            age <= upper) %>%
    dplyr::group_by(geography_code, geography_name, date) %>%
    dplyr::summarise (pop = sum(obs_value))

}
