source("R/functions.R")

panel <- prepare_applicant_panel()

policy_path <- if (file.exists("data/title_ix_policy_directory_snapshot.csv")) {
  "data/title_ix_policy_directory_snapshot.csv"
} else {
  "data/title_ix_policy_directory_sample.csv"
}

policy_directory <- readr::read_csv(policy_path, show_col_types = FALSE)

check_columns(policy_directory, c("institution"), "Title IX policy directory")

if (!"policy_type" %in% names(policy_directory)) {
  policy_directory <- policy_directory |>
    dplyr::mutate(policy_type = NA_character_)
}

policy_flags <- policy_directory |>
  dplyr::mutate(
    institution_clean = clean_institution_name(institution),
    has_pregnant_scholar_listing = TRUE,
    has_pregnancy_accommodation = stringr::str_detect(
      stringr::str_to_lower(dplyr::coalesce(policy_type, "")),
      "pregnancy"
    ),
    has_parental_leave = stringr::str_detect(
      stringr::str_to_lower(dplyr::coalesce(policy_type, "")),
      "parental leave"
    )
  ) |>
  dplyr::group_by(institution_clean) |>
  dplyr::summarise(
    has_pregnant_scholar_listing = any(has_pregnant_scholar_listing),
    has_pregnancy_accommodation = any(has_pregnancy_accommodation),
    has_parental_leave = any(has_parental_leave),
    .groups = "drop"
  )

panel_extension <- panel |>
  dplyr::mutate(institution_clean = clean_institution_name(institution)) |>
  dplyr::left_join(policy_flags, by = "institution_clean") |>
  dplyr::mutate(
    dplyr::across(
      c(has_pregnant_scholar_listing, has_pregnancy_accommodation, has_parental_leave),
      ~ tidyr::replace_na(.x, FALSE)
    )
  )

religious_path <- "data-raw/ocr_title_ix_religious_exemptions.csv"

if (file.exists(religious_path)) {
  religious_exemptions <- readr::read_csv(religious_path, show_col_types = FALSE) |>
    dplyr::mutate(
      institution_clean = clean_institution_name(institution),
      literal_title_ix_religious_exemption = TRUE
    ) |>
    dplyr::distinct(institution_clean, literal_title_ix_religious_exemption)

  panel_extension <- panel_extension |>
    dplyr::left_join(religious_exemptions, by = "institution_clean") |>
    dplyr::mutate(
      literal_title_ix_religious_exemption = tidyr::replace_na(
        literal_title_ix_religious_exemption,
        FALSE
      )
    )
} else {
  panel_extension <- panel_extension |>
    dplyr::mutate(literal_title_ix_religious_exemption = FALSE)
}

readr::write_csv(panel_extension, "data/analysis_title_ix_extension.csv")

message("Wrote extension analysis file to data/analysis_title_ix_extension.csv")

if (dplyr::n_distinct(panel_extension$has_pregnancy_accommodation) > 1) {
  extension_model <- fixest::feols(
    share_female ~
      fixest::i(year, treatment_ban, ref = 2021) +
      fixest::i(year, as.integer(has_pregnancy_accommodation), ref = 2021) |
      institution + year,
    cluster = ~ institution,
    data = panel_extension
  )

  readr::write_csv(
    broom::tidy(extension_model, conf.int = TRUE),
    "results/title_ix_extension_model.csv"
  )

  print(extension_model)
  message("Wrote extension model table to results/title_ix_extension_model.csv")
} else {
  message("No variation in has_pregnancy_accommodation; skipped extension model.")
}

