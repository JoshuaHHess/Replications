#MAKE VARIABLES
#builds df: one row per school-year with repeal, wshare, and rank2023

#===== LOAD DATAFRAMES =====
source(here("scripts","data processing","import data.R"))

#==== COMBINE IPEDS DATA ====
#add directory information to the applications data
df <- df.adm |> left_join(df.hd, join_by(UNITID, year))

#year was extracted from the file name as text; make it a number
df <- df |> mutate(year = as.numeric(year))

#==== POLICY VARIABLE ====
#generate repeal indicator and join it
df <-  df.policy |>
  select(STABBR = Abbreviation, status = `Abortion Status`) |>
  mutate(repeal = if_else(status == "Banned",1,0)) |>
  right_join(df,join_by(STABBR))

#==== OUTCOME VARIABLE ====
df <- df |> mutate(wshare = APPLCNW/(APPLCNW + APPLCNM) )

#==== HETEROGENEOUS VARIABLES ====
#select 2023 rank and join
df <- df.rank |> select(UNITID=IPEDS,rank2023 = `2023`) |>
  right_join(df,join_by(UNITID))
