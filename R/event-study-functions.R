# EVENT-STUDY FUNCTIONS
# assumes tidyverse and fixest have been loaded

# fit a Walker-style event-study model for a supplied outcome and sample
fit_event_study <- function(data,
                            outcome = "wshare",
                            reference_year = 2021) {
  model_formula <- stats::as.formula(
    paste0(
      outcome,
      " ~ i(year, repeal, ref = ",
      reference_year,
      ") | UNITID + STABBR + year"
    )
  )

  fixest::feols(
    model_formula,
    cluster = ~STABBR,
    data = data
  )
}

# turn the i() terms into a dataframe that ggplot can use
tidy_event_study <- function(model, i_select = 1) {
  fixest::iplot(model, i.select = i_select, only.params = TRUE)$prms |>
    tibble::as_tibble() |>
    dplyr::transmute(
      year = as.integer(estimate_names),
      estimate,
      conf.low = ci_low,
      conf.high = ci_high,
      reference = is_ref
    ) |>
    dplyr::arrange(year)
}
