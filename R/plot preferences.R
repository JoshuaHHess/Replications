# PLOTTING FUNCTION
# assumes tidyverse has been loaded

plot_event_study <- function(event_df) {
  ggplot(event_df, aes(x = year, y = estimate)) +
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = .1) +
    geom_point() +
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 2021, linetype = "dashed") +
    labs(
      x = NULL,
      y = "Change in ban-control gap"
    ) +
    theme_minimal()
}
