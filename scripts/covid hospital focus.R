# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  dplyr,
  zoo,
  reshape2,
  lubridate,
  plotly,
  data.table,
  rjson,
  ggthemes,
  extrafont,
  tidyr,
  ggalt,
  directlabels
)

# install fonts
font_import(paths = c("~/Documents/GitHub/dorset_covid"), prompt = F)
extrafont::loadfonts()

# IMPORT DATASETS ----
# Datasets have already been obtained from NHSE using the script hosp_prep.sh
# Skip the first thirteen rows as the headers are in row 14
# Set check.names to FALSE to preserve the headers as-is
hosp_ads <- read.csv("hospital_preparation/hospads.csv", skip = 13, check.names = FALSE)
hosp_bed <- read.csv("hospital_preparation/allbedscovid.csv", skip = 13, check.names = FALSE)
hosp_bmv <- read.csv("hospital_preparation/allbedsmv.csv", skip = 13, check.names = FALSE)
hosp_deaths <- read.csv("hospital_preparation/trustdeaths.csv", skip = 14, check.names = FALSE)

# MUNGE DATA ----

# Delete unwanted columns from hosp_deaths that break the filter below
hosp_deaths <- hosp_deaths[-c(2)]
hosp_deaths <- hosp_deaths[-c(4)]
hosp_deaths <- hosp_deaths[1:(length(hosp_deaths)-4)]

# Remove organisations that aren't RBD or R0D
# Hospitalisations and admissions
hosp_ads <- hosp_ads %>%
  filter(Code=="RBD" | Code=="R0D")

# All covid beds
hosp_bed <- hosp_bed %>%
  filter(Code=="RBD" | Code=="R0D")

# All mechanical ventilation beds
hosp_bmv <- hosp_bmv %>%
  filter(Code=="RBD" | Code=="R0D")

# All deaths
hosp_deaths <- hosp_deaths %>%
  filter(Code=="RBD" | Code=="R0D")

# Convert wide data to long
hosp_ads <- gather(hosp_ads, hdate, hospads_number, "2021/04/07":last_col(), na.rm = FALSE)
hosp_bed <- gather(hosp_bed, hdate, totalbeds_number, "2021/04/07":last_col(), na.rm = FALSE)
hosp_bmv <- gather(hosp_bmv, hdate, mv_number, "2021/04/07":last_col(), na.rm = FALSE)
hosp_deaths <- gather(hosp_deaths, hdate, death_number, "2020/03/01":last_col(), na.rm = FALSE)

# define the date format
hosp_ads$hdate = as.Date(hosp_ads$hdate, "%Y/%m/%d")
hosp_bed$hdate = as.Date(hosp_bed$hdate, "%Y/%m/%d")
hosp_bmv$hdate = as.Date(hosp_bmv$hdate, "%Y/%m/%d")
hosp_deaths$hdate = as.Date(hosp_deaths$hdate, "%Y/%m/%d")

# Remove columns we don't need
hosp_ads <- subset(hosp_ads, hdate > today() - months(3), select = c("Code", "Name", "hdate", "hospads_number"))
hosp_bed <- subset(hosp_bed, hdate > today() - months(3), select = c("Code", "Name", "hdate", "totalbeds_number"))
hosp_bmv <- subset(hosp_bmv, hdate > today() - months(3), select = c("Code", "Name", "hdate", "mv_number"))
hosp_deaths <- subset(hosp_deaths, hdate > today() - months(3), select = c("Code", "Name", "hdate", "death_number"))

# Merge datasets in two operations
# all.x and all.y are TRUE to bring everything across to the combined dataset
hosp_combined <- merge(hosp_ads, hosp_bed, by = c("Code", "Name", "hdate"), all.x = TRUE, all.y = TRUE)
hosp_combined <- merge(hosp_combined, hosp_bmv, by = c("Code", "Name", "hdate"), all.x = TRUE, all.y = TRUE)
hosp_combined <- merge(hosp_combined, hosp_deaths, by = c("Code", "Name", "hdate"), all.x = TRUE, all.y = TRUE)

# The combined dataset is now wide date
# Convert wide data to long
hosp_combined <- gather(hosp_combined, hevent, hnumber, hospads_number:death_number, na.rm = FALSE)

# PLOT DATA ----



