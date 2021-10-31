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
  plotly
)

# IMPORT DATASETS ----

covid_cases_age_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000059&metric=newCasesBySpecimenDateAgeDemographics&format=csv"))
covid_cases_age_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000058&metric=newCasesBySpecimenDateAgeDemographics&format=csv"))

# MUNGE DATA ----

# combine datasets at this point
covid_cases_age_combined <- rbind(covid_cases_age_bcp, covid_cases_age_dor)

# remove rows we don't want
covid_cases_age_combined <- subset(covid_cases_age_combined, age!="00_59")
covid_cases_age_combined <- subset(covid_cases_age_combined, age!="60+")
covid_cases_age_combined <- subset(covid_cases_age_combined, age!="unassigned")

# restrict data to last two months and remove columns we don't want
covid_cases_age_combined <- subset(covid_cases_age_combined, date > today() - days(31), select = c("areaName", "date", "age", "cases"))

# define the date format
covid_cases_age_combined$date = as.Date(covid_cases_age_combined$date, "%Y-%m-%d")

# PLOT DATA ----

# create plot and geom
covid_cases_age_plot <- ggplot() +
  geom_line(data = covid_cases_age_combined, aes(x = date, y = cases, col = age), size = 0.5) +
  geom_point(data = covid_cases_age_combined, aes(x = date, y = cases, col = age, text = paste("Age band:", age, "<br>Cases:", cases, "<br>Date:", date)), size = 1) +
  xlab("Date") +
  ylab("New cases") +
  scale_x_date(date_labels = "%d %B", date_breaks = "1 week") +
  labs(color = "Age bands") +
  ggtitle("Dorset - new covid cases by age group", subtitle = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ")) +
  facet_grid( ~ areaName) +
  theme_bw()

covid_cases_age_plot

# create dynamic plot
covid_cases_age_dynamic_plot <- ggplotly(covid_cases_age_plot)

covid_cases_age_dynamic_plot

# save to daily file
orca(covid_cases_age_dynamic_plot, file = "dorset_age_cases.png")
htmlwidgets::saveWidget(as_widget(covid_cases_age_dynamic_plot), "age_cases.html")
