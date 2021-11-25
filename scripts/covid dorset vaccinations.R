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

covid_vaccs_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000059&metric=newPeopleVaccinatedFirstDoseByVaccinationDate&metric=newPeopleVaccinatedSecondDoseByVaccinationDate&format=csv"))
covid_vaccs_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000058&metric=newPeopleVaccinatedFirstDoseByVaccinationDate&metric=newPeopleVaccinatedSecondDoseByVaccinationDate&format=csv"))

# MUNGE DATA ----

# merge datasets into one
# 1 - place datasets into a single list
vaccs_list <- list(covid_vaccs_bcp,covid_vaccs_dor)

# 2 - merge the datasets in the list into vaccs_combined
vaccs_combined <- merge_recurse(vaccs_list)

# keep only the columns we need, and rename the vacc event columns
vaccs_combined <- subset(vaccs_combined, select = c("date", "areaName", "newPeopleVaccinatedFirstDoseByVaccinationDate", "newPeopleVaccinatedSecondDoseByVaccinationDate"))
names(vaccs_combined)[names(vaccs_combined) == "newPeopleVaccinatedFirstDoseByVaccinationDate"] <- "First"
names(vaccs_combined)[names(vaccs_combined) == "newPeopleVaccinatedSecondDoseByVaccinationDate"] <- "Second"

# define the date format
vaccs_combined$date = as.Date(vaccs_combined$date, "%Y-%m-%d")

# convert wide data into long
vaccs_long <- gather(vaccs_combined, event, total, First, Second)


# PLOT DATA ----

# create plot and geom
covid_vaccs_plot <- ggplot() +
  geom_bar(data = vaccs_long, aes(x = date, y = total, fill = event), stat="identity", position = "stack", width = 0.7) +
  scale_fill_manual(name = "Vaccination", values = c("First" = "paleturquoise3", "Second" = "turquoise4"), labels = c("First", "Second")) +
  facet_grid( ~ areaName) +
  theme_bw() +
  scale_x_date(date_labels = "%B %Y", date_breaks = "2 months") +
  ggtitle("Dorset covid vaccinations by local authority") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ")) +
  xlab("Date") +
  ylab("Vaccinations")

covid_vaccs_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("output/daily_dorset_vaccinations.png", width = 16.6, height = 8.65, units = "in")