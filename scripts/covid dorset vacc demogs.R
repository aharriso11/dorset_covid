# SET COMMON VARIABLES ----
  
# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  tidyr,
  reshape,
  ggtext,
  data.table
)

# IMPORT DATASETS ----

vaccs_demog_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E06000059&metric=vaccinationsAgeDemographics&format=csv"))
vaccs_demog_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E06000058&metric=vaccinationsAgeDemographics&format=csv"))

vaccs_demog_combined <- merge_recurse(vaccs_demog_dor, vaccs_demog_bcp)

