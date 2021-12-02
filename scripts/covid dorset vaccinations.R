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
  reshape,
  lubridate
)

# IMPORT DATASETS ----

covid_vaccs_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000059&metric=newPeopleVaccinatedFirstDoseByVaccinationDate&metric=newPeopleVaccinatedSecondDoseByVaccinationDate&metric=newPeopleVaccinatedThirdInjectionByVaccinationDate&format=csv"))
covid_vaccs_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000058&metric=newPeopleVaccinatedFirstDoseByVaccinationDate&metric=newPeopleVaccinatedSecondDoseByVaccinationDate&metric=newPeopleVaccinatedThirdInjectionByVaccinationDate&format=csv"))

# MUNGE DATA ----

# merge datasets into one
# 1 - place datasets into a single list
vaccs_list <- list(covid_vaccs_bcp,covid_vaccs_dor)

# 2 - merge the datasets in the list into vaccs_combined
vaccs_combined <- merge_recurse(vaccs_list)

# keep only the columns we need, and rename the vacc event columns
vaccs_combined <- subset(vaccs_combined, select = c("date", "areaName", "newPeopleVaccinatedFirstDoseByVaccinationDate", "newPeopleVaccinatedSecondDoseByVaccinationDate", "newPeopleVaccinatedThirdInjectionByVaccinationDate"))
names(vaccs_combined)[names(vaccs_combined) == "newPeopleVaccinatedFirstDoseByVaccinationDate"] <- "First"
names(vaccs_combined)[names(vaccs_combined) == "newPeopleVaccinatedSecondDoseByVaccinationDate"] <- "Second"
names(vaccs_combined)[names(vaccs_combined) == "newPeopleVaccinatedThirdInjectionByVaccinationDate"] <- "Third or booster"

# define the date format
vaccs_combined$date = as.Date(vaccs_combined$date, "%Y-%m-%d")

# restrict to last 9 months
vaccs_combined <- subset(vaccs_combined, date > today() - months(6))

# convert wide data into long
vaccs_long <- gather(vaccs_combined, event, total, First:last_col())


# PLOT DATA ----

# create plot and geom
covid_vaccs_plot <- ggplot() +
  geom_bar(data = vaccs_long, aes(x = date, y = total, fill = event), stat="identity", position = "stack", width = 0.7) +
  scale_fill_manual(name = "Vaccination", values = c("First" = "paleturquoise3", "Second" = "turquoise4", "Third or booster" = "#00413d"), labels = c("First", "Second", "Third or booster")) +
  facet_grid( ~ areaName) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") +
  ggtitle("Dorset covid vaccinations by local authority") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), subtitle = "Daily numbers of new people that have received a COVID-19 vaccination") +
  xlab("Date") +
  ylab("Vaccinations") +
  theme_bw() +
  theme(
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10))

covid_vaccs_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("output/daily_dorset_vaccinations.png", width = 16.6, height = 8.65, units = "in")
