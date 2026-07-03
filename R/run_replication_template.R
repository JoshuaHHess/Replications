source("R/functions.R")

panel <- prepare_applicant_panel()
model <- estimate_event_study(panel)

prefix <- if (file.exists("data-raw/walker_cds_applicants.csv")) "walker" else "toy"
write_analysis_outputs(panel, model, prefix = prefix)

print(model)
message("Wrote analysis data to data/analysis_applicants.csv")
message("Wrote event-study results to results/event_study_", prefix, ".csv")
message("Wrote event-study figure to results/event_study_", prefix, ".png")

