required_packages <- c(
  "readr", "dplyr", "tidyr", "stringr", "ggplot2",
  "fixest", "broom", "scales"
)

missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    "Install missing packages with install.packages(c(",
    paste(sprintf('"%s"', missing_packages), collapse = ", "),
    "))",
    call. = FALSE
  )
}

project_file <- function(...) {
  file.path(getwd(), ...)
}

assert_project_root <- function() {
  if (!file.exists(project_file("_quarto.yml"))) {
    stop("Run this script from the project root, where _quarto.yml is located.", call. = FALSE)
  }
}

check_columns <- function(data, required, data_name = "data") {
  missing_cols <- setdiff(required, names(data))
  if (length(missing_cols) > 0) {
    stop(
      data_name,
      " is missing required columns: ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(data)
}

read_applicant_data <- function(path = NULL) {
  assert_project_root()

  if (is.null(path)) {
    raw_path <- project_file("data-raw", "walker_cds_applicants.csv")
    toy_path <- project_file("data", "example_cds_applicants.csv")
    path <- if (file.exists(raw_path)) raw_path else toy_path
  }

  applicants <- readr::read_csv(path, show_col_types = FALSE)

  check_columns(
    applicants,
    c(
      "institution", "state", "year", "female_applicants",
      "male_applicants", "us_news_rank", "pct_out_state"
    ),
    "applicant data"
  )

  applicants
}

read_abortion_policy <- function(path = project_file("data", "abortion_policy_status_2023.csv")) {
  policy <- readr::read_csv(path, show_col_types = FALSE)
  check_columns(policy, c("state", "walker_status", "treatment_ban"), "abortion policy data")
  policy
}

prepare_applicant_panel <- function(applicants = read_applicant_data(),
                                    policy = read_abortion_policy()) {
  panel <- applicants |>
    dplyr::mutate(
      year = as.integer(year),
      female_applicants = as.numeric(female_applicants),
      male_applicants = as.numeric(male_applicants),
      total_applicants = female_applicants + male_applicants,
      share_female = female_applicants / total_applicants,
      rank_top_50 = us_news_rank <= 50,
      high_out_state = pct_out_state >= 0.50
    ) |>
    dplyr::left_join(
      policy |>
        dplyr::select(state, walker_status, treatment_ban),
      by = "state"
    )

  missing_treatment <- panel |>
    dplyr::filter(is.na(treatment_ban)) |>
    dplyr::distinct(state) |>
    dplyr::pull(state)

  if (length(missing_treatment) > 0) {
    stop(
      "These states are missing treatment status: ",
      paste(missing_treatment, collapse = ", "),
      call. = FALSE
    )
  }

  panel |>
    dplyr::arrange(institution, year)
}

estimate_event_study <- function(panel) {
  check_columns(panel, c("share_female", "year", "treatment_ban", "institution"), "analysis panel")

  fixest::feols(
    share_female ~ fixest::i(year, treatment_ban, ref = 2021) | institution + year,
    cluster = ~ institution,
    data = panel
  )
}

tidy_event_study <- function(model) {
  broom::tidy(model, conf.int = TRUE) |>
    dplyr::mutate(
      year = as.integer(stringr::str_extract(term, "\\d{4}")),
      estimate_pct_points = estimate * 100,
      conf.low_pct_points = conf.low * 100,
      conf.high_pct_points = conf.high * 100
    ) |>
    dplyr::arrange(year)
}

plot_event_study <- function(model) {
  event_terms <- tidy_event_study(model) |>
    dplyr::filter(!is.na(year)) |>
    dplyr::select(year, estimate, conf.low, conf.high)

  plot_data <- dplyr::bind_rows(
    event_terms,
    tibble::tibble(year = 2021L, estimate = 0, conf.low = 0, conf.high = 0)
  ) |>
    dplyr::arrange(year)

  ggplot2::ggplot(plot_data, ggplot2::aes(x = year, y = estimate)) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.4, color = "gray45") +
    ggplot2::geom_vline(xintercept = 2021, linewidth = 0.3, linetype = "dashed", color = "gray60") +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = conf.low, ymax = conf.high),
      width = 0.12,
      color = "#4f6f8f"
    ) +
    ggplot2::geom_point(size = 2.4, color = "#0f6b61") +
    ggplot2::geom_line(color = "#0f6b61", linewidth = 0.7) +
    ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
    ggplot2::scale_x_continuous(breaks = sort(unique(plot_data$year))) +
    ggplot2::labs(
      title = "Event-study estimate for female applicant share",
      subtitle = "Toy data unless data-raw/walker_cds_applicants.csv is present",
      x = NULL,
      y = "Difference relative to 2021",
      caption = "Model: institution and year fixed effects; standard errors clustered by institution."
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title.position = "plot",
      panel.grid.minor = ggplot2::element_blank()
    )
}

write_analysis_outputs <- function(panel, model, prefix = "toy") {
  dir.create(project_file("results"), showWarnings = FALSE, recursive = TRUE)

  readr::write_csv(panel, project_file("data", "analysis_applicants.csv"))
  readr::write_csv(tidy_event_study(model), project_file("results", paste0("event_study_", prefix, ".csv")))

  ggplot2::ggsave(
    filename = project_file("results", paste0("event_study_", prefix, ".png")),
    plot = plot_event_study(model),
    width = 7,
    height = 4.5,
    dpi = 300
  )

  invisible(list(panel = panel, model = model))
}

clean_institution_name <- function(x) {
  x |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("&", " and ") |>
    stringr::str_replace_all("[^a-z0-9]+", " ") |>
    stringr::str_squish()
}

