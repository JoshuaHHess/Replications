required_scrape_packages <- c("readr", "dplyr", "stringr", "rvest", "xml2", "purrr", "tidyr")
missing_scrape_packages <- required_scrape_packages[
  !vapply(required_scrape_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_scrape_packages) > 0) {
  stop(
    "Install missing packages with install.packages(c(",
    paste(sprintf('"%s"', missing_scrape_packages), collapse = ", "),
    "))",
    call. = FALSE
  )
}

source("R/functions.R")

url <- "https://thepregnantscholar.org/policy-directory/"
out_path <- "data/title_ix_policy_directory_snapshot.csv"
sample_path <- "data/title_ix_policy_directory_sample.csv"

message("Reading The Pregnant Scholar policy directory: ", url)

policy <- tryCatch(
  {
    page <- xml2::read_html(url)
    tables <- rvest::html_table(page, fill = TRUE)

    if (length(tables) == 0) {
      stop("No HTML tables found on the page.")
    }

    tables[[which.max(purrr::map_int(tables, nrow))]]
  },
  error = function(e) {
    message("Could not scrape a table from the live page: ", conditionMessage(e))
    message("Using included teaching sample instead: ", sample_path)
    readr::read_csv(sample_path, show_col_types = FALSE)
  }
)

names(policy) <- names(policy) |>
  stringr::str_to_lower() |>
  stringr::str_replace_all("[^a-z0-9]+", "_") |>
  stringr::str_replace_all("^_|_$", "")

if (!"institution" %in% names(policy)) {
  message("The scraped table did not expose an institution column. Using included teaching sample.")
  policy <- readr::read_csv(sample_path, show_col_types = FALSE)
}

policy <- policy |>
  dplyr::mutate(
    institution_clean = clean_institution_name(institution),
    scraped_or_updated_on = as.character(Sys.Date())
  )

readr::write_csv(policy, out_path)
message("Wrote policy snapshot to ", out_path)

