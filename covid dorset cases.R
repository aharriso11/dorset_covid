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
  reshape2
)

# IMPORT DATASETS ----

covid_cases_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000059&metric=newCasesBySpecimenDate&format=csv"))
covid_cases_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000058&metric=newCasesBySpecimenDate&format=csv"))

# MUNGE DATA ----

# apply a seven day rolling average to each table
covid_cases_dor <- covid_cases_dor %>%
  dplyr::mutate(cases_07da_dor = zoo::rollmean(covid_cases_dor$newCasesBySpecimenDate, k = 7, fill = NA))

covid_cases_bcp <- covid_cases_bcp %>%
  dplyr::mutate(cases_07da_bcp = zoo::rollmean(covid_cases_bcp$newCasesBySpecimenDate, k = 7, fill = NA))

# merge bcp and dorset tables into one
covid_cases_com <- merge(covid_cases_bcp, covid_cases_dor, by.x = "date", by.y = "date")

# remove old data we don't want
covid_cases_com <- subset(covid_cases_com, date > "2020-10-31", select = c("date", "cases_07da_bcp", "cases_07da_dor"))

# convert wide data into long
melt.cases <- melt(covid_cases_com, id=c("date"), variable.name = "area", value.name = "cases")

# define the date format
melt.cases$date = as.Date(melt.cases$date, "%Y-%m-%d")

# PLOT DATA ----

# create plot and geom
covid_cases_plot <- ggplot(melt.cases, aes(x = date, y = cases, col = area)) +
  geom_point(shape = 1, size = 2) + scale_colour_manual(name = "Local authority", values = c("cases_07da_dor" = "green4", "cases_07da_bcp" = "darkmagenta"), labels = c("BCP", "Dorset")) +
  labs(caption = paste("Data from Public Health England / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "))

# set plot params
covid_cases_plot + 
  scale_y_continuous(trans = 'log10', breaks = c(5,10,20,50,100,200,500)) +
  scale_x_date(date_labels = "%B %Y", date_breaks = "1 month") +
  ggtitle("Dorset covid cases - 7 day average by specimen date (log scale)") +
  xlab("Date") +
  ylab("Cases") +
  theme_bw()

# save to daily file
ggsave("daily_dorset_cases.png", width = 16.6, height = 8.65, units = "in")