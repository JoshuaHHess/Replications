# ANALYSIS
# creates the main Walker event-study model and figure
# assumes Run All.R has loaded packages and saved maindf.Rdata

#==== LOAD DATA AND FUNCTIONS ====
load(here("data", "saved data", "maindf.Rdata"))
source(here("R", "event-study-functions.R"))
source(here("R", "plot preferences.R"))

#==== DESCRIPTIVE MODELS ====
#pooled, between-school difference -- not a policy estimate
between_model <- feols(
  wshare ~ repeal,
  cluster = ~STABBR,
  data = df
)

#raw event-study differences, before school fixed effects
raw_event_study <- feols(
  wshare ~ repeal +
    i(year, ref = 2021) +
    i(year, repeal, ref = 2021),
  cluster = ~STABBR,
  data = df
)

#==== MAIN EVENT STUDY ====
main_model <- fit_event_study(df)
print(summary(main_model))

#Use this interactively to check the event study before styling it:
#iplot(main_model)

#==== MAIN FIGURE ====
main_event <- tidy_event_study(main_model)
main_plot <- plot_event_study(main_event)

dir.create(here("results", "figures"), recursive = TRUE, showWarnings = FALSE)
ggsave(
  here("results", "figures", "main.png"),
  plot = main_plot,
  width = 6,
  height = 3,
  dpi = 300
)
