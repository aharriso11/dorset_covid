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
  ggthemes
)

# IMPORT DATASET ----

covid_owid_csv <- read.csv(url("https://covid.ourworldindata.org/data/owid-covid-data.csv"))

covid_owid_csv$date = as.Date(covid_owid_csv$date, "%Y-%m-%d")
covid_owid_csv$location = as.factor(covid_owid_csv$location)

owid_countries <- covid_owid_csv %>%
  filter(iso_code=="GBR" | iso_code=="AUT" | iso_code=="NLD" | iso_code=="HUN" | iso_code=="DEU" | iso_code=="BEL")

owid_cases <- subset(owid_countries, date > today() - months(3), select = c("iso_code", "location", "date", "new_cases_smoothed_per_million"))

plot(owid_cases$date, owid_cases$new_cases_smoothed_per_million, type = "o",
     col = as.factor(owid_cases$iso_code))

owid_cases_plot <- ggplot() +
  geom_line(data = owid_cases, aes(x = date, y = new_cases_smoothed_per_million, col = location), size = 0.5, method = "loess") +
  scale_y_continuous(position = "right") +
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  xlab("Date") +
  ylab("New cases per million") +
  ggtitle("Covid cases per million - UK comparison") +
  labs(caption = paste("Data from Our World In Data / https://ourworldindata.org/coronavirus. Plotted", Sys.time(), sep = " "), colour = "Country") +
  theme_bw()

owid_cases_plot

ggsave(plot = owid_cases_plot, width = 16.6, height = 8.65, units = "in", filename = "output/intl_cases.png")
