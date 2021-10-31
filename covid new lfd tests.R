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
  plotly,
  webshot,
  lubridate
)

# IMPORT DATASETS ----

covid_lfd_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E06000059&metric=newLFDTests&format=csv"))
covid_lfd_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E06000058&metric=newLFDTests&format=csv"))

# MUNGE DATA ----

# combine datasets at this point
covid_lfd_combined <- rbind(covid_lfd_dor, covid_lfd_bcp)

# restrict data to last twelve months and remove columns we don't want
covid_lfd_combined <- subset(covid_lfd_combined, date > today() - months(9), select = c("areaName", "date", "newLFDTests"))

# define the date format
covid_lfd_combined$date = as.Date(covid_lfd_combined$date, "%Y-%m-%d")

# PLOT DATA ----

# create plot and geom
covid_lfd_plot <- ggplot() +
  # plot data
  geom_line(data = covid_lfd_combined, aes(x = date, y = newLFDTests, col = areaName), size = 0.5, show.legend = FALSE) +
  # axis settings
  xlab("Date") +
  ylab("New lateral flow device tests recorded") +
  scale_x_date(date_labels = "%B %Y", date_breaks = "2 months") +
  # colour settings
  scale_colour_manual(name = "Local authority", values = c("Dorset" = "green4", "Bournemouth, Christchurch and Poole" = "magenta4")) +
  # title
  ggtitle("Dorset - new lateral flow device tests") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ")) +
  # set facet grid to show each LA in a separate area
  facet_grid( ~ areaName) +
  # set theme
  theme_bw()

covid_lfd_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("daily_lfd.png", width = 16.6, height = 8.65, units = "in")
