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
  ggtext,
  pals
)

# IMPORT DATASETS ----

# get regional cases by specimen date
covid_cases_regions <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=region&metric=newCasesBySpecimenDate&format=csv"))

# MUNGE DATA ----

# restrict data to last nine months and remove columns we don't want
covid_cases_regions <- subset(covid_cases_regions, date > today() - months(3), select = c("areaCode", "areaName", "date", "newCasesBySpecimenDate"))

# sort cases by decreasing date
covid_cases_regions <- covid_cases_regions[rev(order(as.Date(covid_cases_regions$date, format="%Y-%m-%d"))),]

# calculate rolling average grouped by LTLA
covid_cases_regions <- covid_cases_regions %>%
  group_by(areaName) %>%
  dplyr::mutate(region_cases_07da = zoo::rollmean(newCasesBySpecimenDate, k = 7, fill = NA))

# remove most recent five days
less_recent_days <- Sys.Date() - 5
covid_cases_regions <- subset(covid_cases_regions, date < less_recent_days)

# define the date format
covid_cases_regions$date = as.Date(covid_cases_regions$date, "%Y-%m-%d")

# PLOT DATA ----

# create the plot
covid_cases_regions_plot <- ggplot() +
  # background data
  geom_line(data = covid_cases_regions, aes(x = date, y = region_cases_07da, group = areaName, colour = areaName)) +
  # x axis config
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  scale_y_continuous(trans = 'log10', position = "right") +
  scale_colour_manual(name = "English region", values = as.vector(cols25(9))) +
  # labels
  xlab("Date") +
  ylab("New cases 7 day average") +
  # right hand side labels
  #  geom_text(data = plot_labels_right, aes(x = labels_right_x, y = labels_right_y, label = labels_right_text, group = NULL, hjust = "left"), colour = plot_labels_right$labels_right_colour, fontface = "bold", family = "OfficinaSanITC-Book", size = 4, nudge_x = 1, angle = 45) +
  # geom_text(data = subset_top5, aes(x = date, y = sw_cases_07da, label = areaName, group = NULL, hjust = "left"), colour = "lightblue3", fontface = "bold", family = "OfficinaSanITC-Book", size = 2.5, nudge_x = 1, angle = 45) +
  # set title
  ggtitle("England covid cases - 7 day average by specimen date (log scale") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), subtitle = paste0("Daily numbers of new cases (people who have had at least one positive COVID-19 test result). Data are shown by the date the sample was taken from the person being tested.")) +
  # set theme
  theme_base() +
  theme(
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10),
    legend.text = element_text(size = 12),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12))

covid_cases_regions_plot

# save to daily file
ggsave("region_cases.png", width = 16.6, height = 8.65, units = "in")
