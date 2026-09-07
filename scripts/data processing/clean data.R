#CLEAN DATA
#restricts df to the sample in Walker et al. (2023)

#===== LOAD DATAFRAMES =====
source(here("scripts","data processing","make variables.R"))

#==== CLEAN DATA ====
#top 100 in 2023 (104 schools because of ties)
#NA ranks fail the condition, so unranked schools drop out here too
df <- df |> filter(rank2023 <= 100)

#years in the paper
wyrs <- 2018:2022
df <- df |> filter(year %in% wyrs)

#balanced panel: all years present and the outcome never missing
df <- df |> group_by(UNITID) |>
  filter(n_distinct(year) == length(wyrs), all(!is.na(wshare))) |>
  ungroup()
