#' Find the title of a 2011 Census table
#'
#' Returns the Nomis ID of a 2011 Census table based on its ONS title, e.g. 'KS201EW'.
#' This makes it easier to use nomisr's \code{nomis_get_data} function for census tables.
#'
#' @param title A string containing the ONS title of a 2011 Census table.
#'
#' @return A string containing the ID used to identify that table in Nomis.
#'
#' @examples
#' tenure_id <- find_censustable("KS402UK")
#'
#' @export

find_censustable <- function(title) {
  nomisr::nomis_search(name = stringr::str_c(title, "*")) %>%
    dplyr::select(id) %>%
    dplyr::first()
}



#' Get 2011 Census data from Nomis: UK-wide tables
#'
#' Nomis data retreival function. Returns data for some 2011 Census tables if they
#' are designated as UK tables, rather than England & Wales tables. It only works
#' for single-variable tables, and isn't guaranteed to work for all of them.
#'
#' See the census_menu dataset in this package for a list of census tables to try.
#' UK tables are those with a '...UK' suffix.
#'
#' @param title A string containing the ONS title of a 2011 Census table.
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geographic area specified, and columns
#'     for each of the values within the demographic variable covered by the
#'     requested table.
#'
#' @examples
#' oxford_cars <- get_c11_uk(title = "KS404UK", geog = "E07000178")
#'
#' hours_percents <- get_c11_uk(title = "KS604UK", geog = c("S12000036", "S12000046"), output = "p")
#'
#' @export

get_c11_uk <- function (title, geog, output = "n") {

output <- dplyr::case_when(output == "n" ~ "Value",
                    output == "p" ~ "Percent")

nomisr::nomis_get_data(find_censustable(title),
               geography = geog,
               tidy = TRUE,
               select = c("geography_code",
                          "geography_name",
                          "cell_name",
                          "measures_name",
                          "obs_value"))  %>%
  dplyr::filter(measures_name == output) %>%
  dplyr::select("geography_code", "geography_name", "cell_name", "obs_value") %>%
  tidyr::pivot_wider(names_from = "cell_name", values_from = "obs_value") %>%
  janitor::clean_names()
}



#' Get 2011 Census data from Nomis: England & Wales tables
#'
#' Nomis data retreival function. Returns data for most 2011 Census 'Key
#' Statistics' tables if they are designated as England & Wales tables, rather
#' than UK tables. It only works for single-variable tables, and isn't guaranteed
#' to work for all of them.
#'
#' See the census_menu dataset in this package for a list of census tables to try.
#' Key statistics tables for England and Wales have a 'KS' prefix and an 'EW' suffix.
#'
#' @param title A string containing the ONS title of a 2011 Census table.
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geographic area specified, and columns
#'     for each of the values within the demographic variable covered by the
#'     requested table.
#'
#' @examples
#'
#' oxford_cars <- get_c11_ew(title = "KS404EW", geog = "E07000178")
#'
#' hours_percents <- get_c11_ew(title = "KS604EW", geog = c("E06000014", "E07000121"), output = "p")
#'
#' @export


get_c11_ew <- function (title, geog, output = "n") {

  output <- dplyr::case_when(output == "n" ~ "Value",
                      output == "p" ~ "Percent")

  nomisr::nomis_get_data(find_censustable(title),
                 geography = geog,
                 tidy = TRUE,
                 select = c("geography_code",
                            "geography_name",
                            "cell_name",
                            "measures_name",
                            "obs_value",
                            "rural_urban_name")) %>%
    dplyr::filter(measures_name == output,
           rural_urban_name == "Total") %>%
    dplyr::select(-measures_name, -rural_urban_name) %>%
    tidyr::pivot_wider(names_from = "cell_name", values_from = "obs_value") %>%
    janitor::clean_names()
}



#' Get 2011 Census data from Nomis: broad ethnic groups, UK
#'
#' Nomis data retrieval function. Returns data from the 2011 Census on
#' population by ethnic group, using the broad ethnic group classifications
#' used for geographic areas across the UK.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geographic area specified, and a column
#' for each broad ethnic group.
#'
#' @examples
#'
#' Does this show up as commentary text in the example?
#'
#' eth_pop <- c11_ethgrps_uk(geog = c("S12000036", "S12000046"))
#'
#' eth_percent <- c11_ethgrps_uk(geog = c("S12000036", "S12000046"), output = "p")
#'
#' @export

c11_ethgrps_uk <- function(geog, output = "n") {

  get_c11_uk(title = "KS201UK",
             geog = geog,
             output = output)
}



#' Get 2011 Census data from Nomis: broad ethnic groups, England & Wales
#'
#' Nomis data retrieval function. Returns data from the 2011 Census on
#' population by ethnic group, using the broad ethnic group classifications
#' used for geographic areas across England and Wales.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geographic area specified, and a column
#' for each broad ethnic group.
#'
#' @examples
#'
#' eth_pop <- c11_ethgrps_ew(geog = c("E06000014", "E07000121"))
#'
#' eth_percent <- c11_ethgrps_ew(geog = c("E06000014", "E07000121"), output = "p")
#'
#' @export

c11_ethgrps_ew <- function(geog, output = "n") {

  get_c11_ew(title = "KS201EW",
             geog = geog,
             output = output)
}



#' Get 2011 Census data from Nomis: detailed ethnic groups, England & Wales
#'
#' Nomis data retrieval function. Returns data from the 2011 Census on
#' population by detailed ethnic group. Note that outputs with 'and' in the
#' name refer to people who identify with Mixed or Multiple ethnic groups.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#' @param summarise If TRUE, creates a single row for each instance of a detailed
#' ethnic group, even if that detailed group is used across multiple broad groups
#' (e.g 'White: Afghan' and 'Asian: Afghan' totals are added together into a
#' single 'Afghan' row). If FALSE, keeps instances of single ethnic groups separate
#' if they are reported in separate broad groups (e.g. 'White: Afghan' and 'Asian:
#' Afgan' are reported separately). Defaults to FALSE.
#'
#' @return A tibble with a row for each detailed ethnic group for each geographic
#' area specified, and a column showing the number or percentage as specified.
#' If summarise is FALSE, a further column shows the broad ethnic group.
#'
#' @examples
#'
#' eth_pop_full <- c11_ethgrps_ew(geog = c("E06000014", "E07000121"))
#'
#' eth_percent_summary <- c11_ethgrps_ew(geog = c("E06000014", "E07000121"), output = "p", summarise = TRUE)
#'
#' @export

c11_ethdetail_ew <- function (geog, output = "n", summarise = FALSE) {

  output <- dplyr::case_when(output == "n" ~ "Value",
                      output == "p" ~ "Percent")

  df <- nomisr::nomis_get_data("NM_575_1",
                       geography = geog,
                       tidy = TRUE,
                       select = c("geography_code",
                                  "geography_name",
                                  "cell_name",
                                  "measures_name",
                                  "obs_value",
                                  "rural_urban_name")) %>%
    dplyr::filter(measures_name == output,
           rural_urban_name == "Total") %>%
    dplyr::select(-measures_name, -rural_urban_name) %>%
    tidyr::separate(cell_name, into = c("broad_group", "detailed_group"), sep = ": ") %>%
    dplyr::rename(total = obs_value)

  if (summarise == TRUE) {

    df %>% dplyr::group_by(geography_code, geography_name, detailed_group) %>%
      dplyr::summarise(total = sum(total)) %>%
      dplyr::filter(detailed_group != "Ethnic group") %>%
      dplyr::arrange(geography_name, desc(total))

  }


  else {
    df %>%
      dplyr::filter(detailed_group != "Ethnic group") %>%
      dplyr::arrange(geography_name, detailed_group)
  }


}


#' Get 2011 Census data from Nomis: housing tenure, UK
#'
#' Nomis data retrieval function. Returns data from the 2011 Census on
#' housing tenure (i.e home ownership and social/private renting). Works for
#' all available Census geographies in the UK.
#'
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geographic area specified, and columns
#'     for each tenure group.
#'
#' @examples
#'
#' tenure_pop <- c11_tenure_uk(geog = c("E06000014", "E07000121"))
#'
#' cob_percent <- c11_tenure_uk(geog = c("E06000014", "E07000121"), output = "p")
#'
#' @export

c11_tenure_uk <- function(geog, output = "n") {

  get_c11_uk(title ="KS402UK",
             geog = geog,
             output = output) %>%
    dplyr::mutate(other = shared_ownership_part_owned_and_part_rented +
             living_rent_free) %>%
    dplyr::select(-private_rented_private_landlord_or_letting_agency,
           -private_rented_other,
           -shared_ownership_part_owned_and_part_rented,
           -living_rent_free) %>%
    dplyr::rename(owned_total = owned,
           owned_outright = owned_owned_outright,
           owned_mortgage = owned_owned_with_a_mortgage_or_loan,
           social_rent_total = social_rented,
           social_rent_council = social_rented_rented_from_council_local_authority,
           social_rent_ha = social_rented_other)
}



#' Get 2011 Census data from Nomis: country of birth (broad groups), UK
#'
#' Nomis data retrieval function. Returns data from the 2011 Census on
#' country of birth, categorising countries into broad areas (UK, Ireland,
#' 'Other EU', 'Rest of World'). Works for all available UK geographies.
#'
#' @param geog A string or vector of strings specifying geographic areas using ONS nine-digit codes, (e.g "E07000178")
#' @param output Specify "n" for counts or "p" for percentages. Defaults to "n".
#'
#' @return A tibble with a row for each geographic area specified, and columns
#'     for each of the broad country of birth groups listed above.
#'
#' @examples
#'
#' cob_pop <- c11_cob_uk(geog = c("E06000014", "E07000121"))
#'
#' cob_percent <- c11_cob_uk(geog = c("E06000014", "E07000121"), output = "p")
#'
#' @export


c11_cob_uk <- function(geog, output = "n") {

  get_c11_uk(title = "QS203UK",
             geog = geog,
             output = output) %>%
    janitor::clean_names() %>%
    dplyr::select(geography_code, geography_name, dplyr::any_of(cob_headlines$list)) %>%
    dplyr::transmute(geography_code = geography_code,
              geography_name = geography_name,
              uk = europe_united_kingdom_total,
              ireland = europe_ireland,
              other_eu = europe_other_europe_eu_countries_total,
              rest_europe = europe_other_europe_rest_of_europe_total,
              rest_world = africa_total +
                antarctica_and_oceania_total +
                middle_east_and_asia_total +
                the_americas_and_the_caribbean_total +
                other)
}
