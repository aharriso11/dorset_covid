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

covid_owid_vaccs_csv <- read.csv(url("https://github.com/owid/covid-19-data/raw/master/public/data/vaccinations/vaccinations.csv"))

covid_owid_vaccs_csv$date = as.Date(covid_owid_vaccs_csv$date, "%Y-%m-%d")

owid_countries <- covid_owid_vaccs_csv %>%
  filter(iso_code=="GBR" | iso_code=="AUT" | iso_code=="NLD" | iso_code=="HUN" | iso_code=="DEU" | iso_code=="BEL")

owid_vaccs <- subset(owid_countries, date > today() - months(3), select = c("iso_code", "location", "date", "daily_vaccinations_per_million"))

owid_vaccs_plot <- ggplot() +
  geom_line(data = owid_vaccs, aes(x = date, y = daily_vaccinations_per_million, col = location), size = 0.5, method = "loess") +
  scale_y_continuous(position = "right") +
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  xlab("Date") +
  ylab("Daily vaccinations per million") +
  ggtitle("Covid daily vaccinations per million - UK comparison") +
  labs(caption = paste("Data from Our World In Data / https://ourworldindata.org/coronavirus. Plotted", Sys.time(), sep = " "), colour = "Country") +
  theme_bw()

owid_vaccs_plot

ggsave(plot = owid_vaccs_plot, width = 16.6, height = 8.65, units = "in", filename = "intl_vaccs.png")
