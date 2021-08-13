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
  reshape
)

# IMPORT DATASETS ----

# ods ready reckoner for people who aren't nhs nerds
# rbd = Dorset County Hospital NHS Foundation Trust
# r0d = University Hospitals Dorset NHS Foundation Trust
# rdy = Dorset HealthCare University NHS Foundation Trust

admissions_rbd <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=nhsTrust&areaCode=RBD&metric=newAdmissions&format=csv"))
admissions_r0d <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=nhsTrust&areaCode=R0D&metric=newAdmissions&format=csv"))
admissions_rdy <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=nhsTrust&areaCode=RDY&metric=newAdmissions&format=csv"))

# MUNGE DATA ----

#merge datasets into one
admissions_list <- list(admissions_rbd, admissions_r0d, admissions_rdy)
admissions_data_combined <- merge_recurse(admissions_list)

# define the date format
admissions_data_combined$date = as.Date(admissions_data_combined$date, "%Y-%m-%d")

# PLOT DATA ----

# create plot and geom
admissions_plot <- ggplot(admissions_data_combined, aes(x = date, y = newAdmissions, col = areaName)) +
  geom_point(shape = 1, size = 2) + scale_colour_manual(name = "NHS Trust", values = c("Dorset County Hospital NHS Foundation Trust" = "red", "University Hospitals Dorset NHS Foundation Trust" = "darkmagenta", "Dorset Healthcare University NHS Foundation Trust" = "chartreuse2")) +
  labs(caption = paste("Data from Public Health England / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "))

# set plot params
admissions_plot +
#  scale_y_continuous(trans = 'log10', breaks = c(1,5,10,20,60)) +
  xlab("Date") +
  ylab("Admissions") +
  ggtitle("Dorset NHS Trusts - daily covid admissions") +
  theme_bw()

# save to daily file
ggsave("daily_dorset_admissions.png", width = 16.6, height = 8.65, units = "in")
