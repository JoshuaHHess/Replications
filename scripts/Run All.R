#RUN ALL

#===== LOAD PACKAGES =====
if (!require("pacman")) {
  install.packages("pacman")
}
pacman::p_load(readxl, here, tidyverse, modelsummary)

#===== COMPILE DATA =====
source(here("scripts","data processing","import data.R"))
source(here("scripts","data processing","make variables.R"))
source(here("scripts","data processing","clean data.R"))
save(df, file = here("data","saved data","maindf.Rdata"))
