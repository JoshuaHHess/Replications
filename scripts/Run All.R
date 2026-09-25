#RUN ALL

#===== LOAD PACKAGES =====
options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}
pacman::p_load(readxl, here, tidyverse, modelsummary, fixest)

#===== COMPILE DATA =====
source(here("scripts","data processing","import data.R"))
source(here("scripts","data processing","make variables.R"))
source(here("scripts","data processing","clean data.R"))
save(df, file = here("data","saved data","maindf.Rdata"))

#===== ANALYSIS =====
source(here("scripts","analysis","main.R"))
