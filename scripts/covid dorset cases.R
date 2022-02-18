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
  ggtext,
  ggthemes
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
less_recent_days <- Sys.Date() - 5
covid_cases_com <- subset(covid_cases_com, date > today() - months(12), select = c("date", "cases_07da_bcp", "cases_07da_dor"))
covid_cases_com <- subset(covid_cases_com, date < less_recent_days)

# convert wide data into long
melt.cases <- melt(covid_cases_com, id=c("date"), variable.name = "area", value.name = "cases")

# define the date format
melt.cases$date = as.Date(melt.cases$date, "%Y-%m-%d")

# get latest dorset figure
latest_dor <- melt.cases %>%
  filter(area=="cases_07da_dor") %>%
  tail(1)

# get latest bcp figure
latest_bcp <- melt.cases %>%
  filter(area=="cases_07da_bcp") %>%
  tail(1)

# PLOT DATA ----

# create plot and geom
covid_cases_plot <- ggplot() +
  geom_point(data = melt.cases, aes(x = date, y = cases, col = area), shape = 1, size = 2, show.legend = FALSE) + 
  geom_hline(yintercept = latest_dor$cases, linetype = "dotted", colour = "green4", size = 0.75) +
  geom_hline(yintercept = latest_bcp$cases, linetype = "dotted", colour = "magenta4", size = 0.75) +
  scale_colour_manual(name = "Local authority", values = c("cases_07da_dor" = "green4", "cases_07da_bcp" = "magenta4"), labels = c("BCP", "Dorset")) +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), subtitle = paste0("Daily numbers of new cases (people who have had at least one positive COVID-19 test result) in <span style='color:green4;'>Dorset</span> and <span style='color:magenta4;'>BCP</span>. Data are shown by the date the sample was taken from the person being tested.")) +
  scale_y_continuous(position = "right") +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") +
  ggtitle("Dorset covid cases - 7 day average by specimen date (linear scale)") +
  xlab("Date") +
  ylab("Cases") +
  theme_base() +
  theme(
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 12),
    plot.caption = element_text(size = 11))

covid_cases_plot

# save to daily file
ggsave("output/daily_dorset_cases.png", width = 16.6, height = 8.65, units = "in")
