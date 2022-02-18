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
  lubridate,
  ggthemes,
  ggtext
)

# IMPORT DATASET ----

covid_cases_csv <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newCasesBySpecimenDate&format=csv"))

# MUNGE DATA ----

# set the date format
covid_cases_csv$date = as.Date(covid_cases_csv$date, "%Y-%m-%d")

# calculate seven day rolling average
covid_cases_csv <- covid_cases_csv %>%
  dplyr::mutate(cases_07da = zoo::rollmean(newCasesBySpecimenDate, k = 7, fill = NA))

# restrict to last twelve months
covid_cases_csv <- subset(covid_cases_csv, date>today() - months(12))

# remove most recent five days
less_recent_days <- Sys.Date() - 5
less_seven_days <- less_recent_days - 7
covid_cases_subset <- subset(covid_cases_csv, date < less_recent_days)

# get most recent 07da
latest07da <- head(covid_cases_subset$cases_07da,1)

# PLOT DATA ----

# set plot and geom
covid_cases_plot <- ggplot() +
  # plot cases
  geom_point(data = covid_cases_subset, aes(x = date, y = cases_07da), shape = 1, colour = "red", size = 2) +
  geom_hline(yintercept = latest07da, linetype = "dotted", colour = "red", size = 0.75) +
  # plot trend line
  geom_smooth(data = subset(covid_cases_csv, covid_cases_csv$date >= less_seven_days), aes(x = date, y = cases_07da), method = "lm", colour = "black", size=0.5, fullrange=FALSE, se=FALSE) +
  # set x and y axis
  scale_y_continuous(trans = 'log10', breaks = c(1000,2000,5000,10000,20000,50000,120000), position = "right") +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") +
  xlab("Date") +
  ylab("Cases") +
  # set title, subtitle and caption
  ggtitle("England covid cases - 7 day average by specimen date (log scale)") +
  labs(caption = paste0("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted ", Sys.time(), sep = " "), subtitle = paste0("Daily numbers of new cases (people who have had at least one positive COVID-19 test result). Data are shown by the date the sample was taken from the person being tested.")) +
  # set theme
  theme_base() +
  theme(
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 12),
    plot.caption = element_text(size = 11))

# create plot
covid_cases_plot

# save to daily file
ggsave("output/daily_england_cases.png", width = 16.6, height = 8.65, units = "in")