# SET COMMON VARIABLES ----

# set working directory
setwd("/Users/andrewharrison/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  dplyr,
  zoo,
  reshape2,
  plotly
)

# IMPORT DATASETS ----

covid_cases_msoa_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=msoa&areaCode=E06000059&metric=newCasesBySpecimenDateRollingRate&format=csv"))
covid_cases_msoa_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=msoa&areaCode=E06000058&metric=newCasesBySpecimenDateRollingRate&format=csv"))
#bcp data

# MUNGE DATA ----

#combine datasets at this point
covid_cases_msoa_combined <- rbind(covid_cases_msoa_bcp, covid_cases_msoa_dor)

# remove data we don't want
covid_cases_msoa_combined <- subset(covid_cases_msoa_combined, date > "2021-07-01", select = c("UtlaName", "areaName", "date", "newCasesBySpecimenDateRollingRate"))

# define the date format
covid_cases_msoa_combined$date = as.Date(covid_cases_msoa_combined$date, "%Y-%m-%d")

# PLOT DATA ----

# create plot and geom
covid_cases_msoa_plot <- ggplot() +
  geom_smooth(data = covid_cases_msoa_combined, aes(x = date, y = newCasesBySpecimenDateRollingRate, col = areaName), size = 0.5) +
  geom_point(data = covid_cases_msoa_combined, aes(x = date, y = newCasesBySpecimenDateRollingRate, col = areaName, text = paste("MSOA:", areaName, "<br>Rate:", newCasesBySpecimenDateRollingRate, "<br>Date:", date)), size = 1) +
  xlab("Date") +
  ylab("New cases by specimen date rolling rate") +
  labs(color = "MSOAs") +
  ggtitle("Dorset MSOAs - weekly covid rolling rate", subtitle = paste("Data from Public Health England / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "))
  
# create dynamic plot
covid_cases_msoa_dynamic_plot <- ggplotly(covid_cases_msoa_plot, tooltip = c("text"))

covid_cases_msoa_dynamic_plot

# save to daily file
htmlwidgets::saveWidget(as_widget(covid_cases_msoa_dynamic_plot), "msoa_cases.html")

