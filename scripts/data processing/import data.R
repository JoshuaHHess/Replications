#==== LOAD PACKAGES =====
#load pacman to facilitate package loading
suppressMessages(install.packages("pacman",quiet = TRUE)) #do this quietly to suppress installation messages
library(pacman)

#load other packages
pacman::p_load(readxl,here)

#auto installs:ggplot2, tibble, tidyr, readr, purrr, dplyr, stringr, forcats
pacman::p_load(tidyverse)

#==== IMPORT RANKINGS DATA ====
#set original data folder path
data.path <- here("data","original data")
df.rank <- read_excel(here(data.path, "USNWR.xlsx"))

#==== IMPORT ADM DATA ====
#build ADM folder path
folder.path <- here(data.path,"IPEDS","ADM")

#get list of files in ADM folder
lf <- list.files(folder.path)

#read files and add year variable
##initialize dataframe
ll <- 1
df <- read_csv(here(folder.path,lf[ll])) |> 
  mutate(year = lf[ll] |> str_extract("\\d{4}+"))

##loop over remaining files
for (ll in 2:length(lf)){
  #read file and add year variable
  df2 <- read_csv(here(folder.path,lf[ll])) |>
    mutate(year = lf[ll] |> str_extract("\\d{4}+"))
  
  #bind to exisiting dataframe
  df <- df |> bind_rows(df2)
}

df.adm <- df
rm(folder.path,lf,ll,df,df2)

#==== IMPORT HD DATA ====
#set HD file path
folder.path <- here("data","original data","IPEDS","HD")

#get list of files in HD folder
lf <- list.files(folder.path)

##initialize dataframe
ll <- 1
df <- read_csv(here(folder.path,lf[ll])) |>
  mutate(year = lf[ll] |> str_extract("\\d{4}+"))

##loop over remaining files
for (ll in 2:length(lf)){
  #read file and add year variable
  df2 <- read_csv(here(folder.path,lf[ll])) |>
    mutate(year = lf[ll] |> str_extract("\\d{4}+"))
  
  #bind to exisiting dataframe
  df <- df |> bind_rows(df2)
}

df.hd <- df
rm(folder.path,lf,ll,df,df2)

#==== IMPORT STATE POLICY DATA ====
df.policy <- read_excel(here(data.path,"Table 1.xlsx"))
