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
  extrafont
)

# install fonts
loadfonts()

# IMPORT DATASETS ----

# encode url for ONS open geography portal - local authority district to region lookup (April 2021)
# url needs to be encoded so we can use it with fromJSON
region_json_url <- URLencode('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD21_RGN21_EN_LU/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json')

# get LTLA to region lookup data
region_json_data <- jsonlite::fromJSON(region_json_url)

# extract the lookup table into a dataframe
region_data <- data.table(region_json_data$features)

# get LTLA new cases by specimen date
covid_cases_ltla <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&metric=newCasesBySpecimenDate&format=csv"))


# MUNGE DATA ----

# create new dataframe to filter south west (E12000009) LTLAs only
region_data_sw <- region_data %>%
  filter(attributes.RGN21CD=="E12000009")

# create new dataframe to show only south west LTLA cases
# merge by LTLA code not name to ensure merged Cornwall and Scilly Isles case data are matched
covid_cases_sw <- merge(x = covid_cases_ltla, y = region_data_sw, by.x = c("areaCode"), by.y = c("attributes.LAD21CD"))

# restrict data to last nine months and remove columns we don't want
covid_cases_sw <- subset(covid_cases_sw, date > today() - months(3), select = c("areaCode", "areaName", "date", "newCasesBySpecimenDate"))

# sort cases by decreasing date
covid_cases_sw <- covid_cases_sw[rev(order(as.Date(covid_cases_sw$date, format="%Y-%m-%d"))),]

# calculate rolling average grouped by LTLA
covid_cases_sw <- covid_cases_sw %>%
  group_by(areaName) %>%
  dplyr::mutate(sw_cases_07da = zoo::rollmean(newCasesBySpecimenDate, k = 7, fill = NA))

# remove most recent five days
less_recent_days <- Sys.Date() - 5
covid_cases_sw <- subset(covid_cases_sw, date < less_recent_days)

# define the date format
covid_cases_sw$date = as.Date(covid_cases_sw$date, "%Y-%m-%d")

# CREATE DATA SUBSETS

# define latest date
latest_date <- head(covid_cases_sw$date, 1)

# Top 5 subset
subset_date <- covid_cases_sw %>%
  filter(date==latest_date)

subset_top5 <- subset_date[with(subset_date,order(-newCasesBySpecimenDate)),]
subset_top5 <- subset_top5[1:5,]

# Dorset subset
subset_dor <- covid_cases_sw %>% 
  filter(areaName=="Dorset") 

# BCP subset
subset_bcp <- covid_cases_sw %>%
  filter(areaName=="Bournemouth, Christchurch and Poole")

# Immensa subset
subset_immensa <- covid_cases_sw %>%
  filter(areaCode=="E06000022" | areaCode=="E06000023" | areaCode=="E06000024" | areaCode=="E06000025" | areaCode=="E06000030" | areaCode=="E07000078" | areaCode=="E07000079" | areaCode=="E07000081" | areaCode=="E07000082" | areaCode=="E07000083" | areaCode=="E07000188" | areaCode=="E07000246")

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
covid_cases_sw_plot <- ggplot() +
  # background data
  geom_line(data = covid_cases_sw, aes(x = date, y = sw_cases_07da, group = areaName, colour = areaName), colour = "lightblue3") +
  # Immensa lines
  geom_line(data = subset_immensa, aes(x = date, y = sw_cases_07da, group = areaName, colour = areaName), colour = "red3") +
  # Dorset line
  geom_line(data = subset_dor, aes(x = date, y = sw_cases_07da, group = areaName, colour = areaName), colour = "green4", size = 1) +
  # BCP line
  geom_line(data = subset_bcp, aes(x = date, y = sw_cases_07da, group = areaName, colour = areaName), colour = "magenta4", size = 1) +
  # x axis config
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  scale_y_continuous(position = "right") +
  # labels
  xlab("Date") +
  ylab("New cases 7 day average") +
  # right hand side labels
  #  geom_text(data = plot_labels_right, aes(x = labels_right_x, y = labels_right_y, label = labels_right_text, group = NULL, hjust = "left"), colour = plot_labels_right$labels_right_colour, fontface = "bold", family = "OfficinaSanITC-Book", size = 4, nudge_x = 1, angle = 45) +
  # geom_text(data = subset_top5, aes(x = date, y = sw_cases_07da, label = areaName, group = NULL, hjust = "left"), colour = "lightblue3", fontface = "bold", family = "OfficinaSanITC-Book", size = 2.5, nudge_x = 1, angle = 45) +
  # set title
  ggtitle("New covid cases - Dorset comparison with south west lower tier local authorities") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ")) +
  # set theme
  theme_economist(base_family="OfficinaSanITC-Book") +
  theme(axis.line.x = element_line(size=.5, colour = "black"),
        legend.position="bottom", 
        legend.direction="horizontal", 
        legend.title = element_blank(),
        plot.title=element_text(family="OfficinaSanITC-Book"),
        text=element_text(family="OfficinaSanITC-Book"))

covid_cases_sw_plot

# save to daily file
ggsave("sw_cases.png", width = 16.6, height = 8.65, units = "in")

# create dynamic plot
covid_cases_sw_dynamic_plot <- ggplotly(covid_cases_sw_plot)
covid_cases_sw_dynamic_plot

# save to daily file
ggsave("sw_cases.png", width = 16.6, height = 8.65, units = "in")
htmlwidgets::saveWidget(as_widget(covid_cases_sw_dynamic_plot), "sw_cases.html")
