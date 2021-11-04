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
  ggthemes,
  extrafont
)

# install fonts
loadfonts()

# IMPORT DATASETS ----

covid_cases_utlas <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&metric=newCasesBySpecimenDate&format=csv"))

# MUNGE DATA ----

# restrict data to last nine months and remove columns we don't want
covid_cases_utlas <- subset(covid_cases_utlas, date > today() - months(9), select = c("areaName", "date", "newCasesBySpecimenDate"))

# calculate rolling average grouped by UTLA
covid_cases_utlas <- covid_cases_utlas %>%
  group_by(areaName) %>%
  dplyr::mutate(utla_cases_07da = zoo::rollmean(newCasesBySpecimenDate, k = 7, fill = NA))

# remove most recent five days
less_recent_days <- Sys.Date() - 5
covid_cases_utlas <- subset(covid_cases_utlas, date < less_recent_days)

# define the date format
covid_cases_utlas$date = as.Date(covid_cases_utlas$date, "%Y-%m-%d")

# CREATE DATA SUBSETS

# define latest date
latest_date <- head(covid_cases_utlas$date, 1)

# Top 5 subset
subset_date <- covid_cases_utlas %>%
  filter(date==latest_date)

subset_top5 <- subset_date[with(subset_date,order(-newCasesBySpecimenDate)),]
subset_top5 <- subset_top5[1:5,]

# Dorset subset
subset_dor <- covid_cases_utlas %>% 
  filter(areaName=="Dorset") 

# BCP subset
subset_bcp <- covid_cases_utlas %>%
  filter(areaName=="Bournemouth, Christchurch and Poole")

# define Dorset and BCP latest figures
latest_dor <- head(subset_dor$newCasesBySpecimenDate, 1)
latest_bcp <- head(subset_bcp$newCasesBySpecimenDate, 1)
latest_date_dor <- head(subset_dor$date, 1)
latest_date_bcp <- head(subset_bcp$date, 1)

# right hand side labels dataset
labels_right_x <- c(latest_date_dor, latest_date_bcp)
labels_right_y <- c(latest_dor, latest_bcp)
labels_right_text <- c("Dorset", "BCP")
labels_right_colour <- c("green4", "magenta4")
plot_labels_right <- data.table(labels_right_x = labels_right_x, labels_right_y = labels_right_y, labels_right_text = labels_right_text, labels_right_colour = labels_right_colour)

# PLOT DATA ----

# create the plot
covid_cases_utlas_plot <- ggplot() +
  # background data
  geom_line(data = covid_cases_utlas, aes(x = date, y = utla_cases_07da, group = areaName, colour = areaName), colour = "lightblue3") +
  # Dorset line
  geom_line(data = subset_dor, aes(x = date, y = utla_cases_07da, group = areaName, colour = areaName), colour = "green4", size = 2) +
  # BCP line
  geom_line(data = subset_bcp, aes(x = date, y = utla_cases_07da, group = areaName, colour = areaName), colour = "magenta4", size = 2) +
  # x axis config
  scale_x_date(date_labels = "%B %Y", date_breaks = "1 month") +
  scale_y_continuous(position = "right") +
  # labels
  xlab("Date") +
  ylab("New cases 7 day average") +
  # right hand side labels
  geom_text(data = plot_labels_right, aes(x = labels_right_x, y = labels_right_y, label = labels_right_text, group = NULL, hjust = "left"), colour = plot_labels_right$labels_right_colour, fontface = "bold", family = "OfficinaSanITC-Book", size = 4, nudge_x = 1, angle = 45) +
  geom_text(data = subset_top5, aes(x = date, y = utla_cases_07da, label = areaName, group = NULL, hjust = "left"), colour = "lightblue3", fontface = "bold", family = "OfficinaSanITC-Book", size = 3, nudge_x = 1, angle = 45) +
  # set title
  ggtitle("New covid cases - Dorset comparison with England upper tier local authorities") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ")) +
  # set theme
  theme_economist(base_family="OfficinaSanITC-Book") +
  theme(axis.line.x = element_line(size=.5, colour = "black"),
        legend.position="bottom", 
        legend.direction="horizontal", 
        legend.title = element_blank(),
        plot.title=element_text(family="OfficinaSanITC-Book"),
        text=element_text(family="OfficinaSanITC-Book"))
  
covid_cases_utlas_plot


# SAVE OUTPUT ----

# save to daily file
ggsave("daily_cases_utlas.png", width = 16.6, height = 8.65, units = "in")
