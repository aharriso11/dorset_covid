# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  tidyr,
  reshape
)

# IMPORT DATASETS ----

vaccs_percentage_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000059&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&format=csv"))
vaccs_percentage_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000058&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&format=csv"))

# MUNGE DATA ----

# merge datasets into one
# 1 - place datasets into a single list
vaccs_percentage_list <- list(vaccs_percentage_dor, vaccs_percentage_bcp)

# 2 - merge the datasets in the list into vaccs_combined
vaccs_percentage_combined <- merge_recurse(vaccs_percentage_list)

# keep only the columns we need, and rename the vacc event columns
vaccs_percentage_combined <- subset(vaccs_percentage_combined, select = c("date", "areaName", "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage", "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage"))
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage"] <- "First"
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage"] <- "Second"

# define the date format
vaccs_percentage_combined$date = as.Date(vaccs_percentage_combined$date, "%Y-%m-%d")

# convert wide data into long
vaccs_percentage_long <- gather(vaccs_percentage_combined, event, total, First:Second)

# PLOT DATA ----

# create plot and geom
covid_vaccs_percentage_plot <- ggplot() +
  geom_area(data = vaccs_percentage_long, aes(x = date, y = total, group = event, fill = event), position = "dodge") +
  scale_fill_manual(name = "Vaccination", values = c("First" = "paleturquoise3", "Second" = "turquoise4"), labels = c("First", "Second")) +
  facet_grid( ~ areaName) +
  theme_bw() +
  scale_x_date(date_labels = "%B %Y", date_breaks = "2 months") +
  ggtitle("Dorset covid vaccinations by local authority - population percentage over time") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ")) +
  xlab("Date") +
  ylab("Vaccinations") +
  scale_y_continuous(breaks = c(20, 40, 60, 80, 100), labels = scales::percent_format(scale = 1), limits = c(0,100))

covid_vaccs_percentage_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("output/daily_dorset_vaccs_percentage.png", width = 16.6, height = 8.65, units = "in")