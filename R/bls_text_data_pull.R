# Script Location
here::i_am("R/bls_text_data_pull.R")
# Library Load Block
library(here)
library(rvest)

# Function Block
bls_download <- function(hyperlink) {
  # Creating a Vector for the File Label
  modified_hyperlink <-
    hyperlink |>
    stringr::str_split("/") |>
    purrr::simplify()
  # Selecting Last Position in Vector
  title <- modified_hyperlink[[length(modified_hyperlink)]]
  # Check to Make Sure its not a directory
  if (title != "") {
    # Using Here to simplify file location
    report_title <- here::here("data", title)
    # Checking to see if file already exists
    if (fs::file_exists(report_title)) {
      return("File already Downloaded")
    } else {
      curl::curl_download(hyperlink, report_title)
      return(report_title)
    }
  } else {
    # Return Directory
    return("This link is not a file, it is probably a directory")
  }
}

bls_links <- function(hyperlink,
                      base_link = "https://download.bls.gov") {
  # Extracting Links
  links <- hyperlink |>
    xml2::read_html() |>
    rvest::html_elements("a") |>
    rvest::html_attr("href") |>
    tibble::as_tibble()
  # Creating Links that work
  vectorized_links <- glue::glue("{base_link}", "{links[[1]]}")
  return(vectorized_links)
}

# Want to add a file check to see if the files already exist before downloading

# Variable Definition
bls_download_link <- "https://download.bls.gov"
laus_site <- "https://download.bls.gov/pub/time.series/la/"
oes_site <- "https://download.bls.gov/pub/time.series/oe/"
sae_site <- "https://download.bls.gov/pub/time.series/sm/"

# Collecting Links
laus_links <- bls_links(laus_site)
oes_links <- bls_links(oes_site)
sae_links <- bls_links(sae_site)

# Downloading Text Files
purrr::map(.x = laus_links, .f = bls_download)
purrr::map(.x = oes_links, .f = bls_download)
purrr::map(.x = sae_links, .f = bls_download)
