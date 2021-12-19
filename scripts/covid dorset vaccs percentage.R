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
  ggtext,
  data.table
)

# IMPORT DATASETS ----

vaccs_percentage_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000059&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))
vaccs_percentage_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&areaCode=E06000058&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))
vaccs_percentage_eng <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))

# MUNGE DATA ----

# merge datasets into one
# 1 - place datasets into a single list
vaccs_percentage_list <- list(vaccs_percentage_dor, vaccs_percentage_bcp)

# 2 - merge the datasets in the list into vaccs_combined
vaccs_percentage_combined <- merge_recurse(vaccs_percentage_list)

# keep only the columns we need, and rename the vacc event columns
vaccs_percentage_combined <- subset(vaccs_percentage_combined, select = c("date", "areaName", "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage", "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage", "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"))
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage"] <- "First"
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage"] <- "Second"
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"] <- "Third or booster"

# define the date format
vaccs_percentage_combined$date = as.Date(vaccs_percentage_combined$date, "%Y-%m-%d")

# convert wide data into long
vaccs_percentage_long <- gather(vaccs_percentage_combined, event, total, First:last_col())

# get latest England figure for boosters
latest_eng <- head(vaccs_percentage_eng$cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage, 1)
first_date <- tail(vaccs_percentage_long$date, 1)

label_eng_text <- "Dotted line indicates \nEngland third or \nbooster percentage"
label_eng_colour <- "#00413d"
plot_label_eng <- data.table(label_eng_x = first_date, label_eng_y = latest_eng, label_eng_text = label_eng_text, label_eng_colour = label_eng_colour)

# PLOT DATA ----

# create plot and geom
covid_vaccs_percentage_plot <- ggplot() +
  geom_area(data = vaccs_percentage_long, aes(x = date, y = total, group = event, fill = event), position = "dodge") +
  geom_hline(yintercept = latest_eng, linetype = "dotted", colour = "#00413d", size = 0.5) +
  geom_label(data = plot_label_eng, aes(x = label_eng_x, y = label_eng_y, label = label_eng_text, group = NULL, hjust = "left"), fill = plot_label_eng$label_eng_colour, colour = "white", fontface = "bold", size = 2.5, nudge_x = 0, nudge_y = 6) +
  scale_fill_manual(name = "Vaccination", values = c("First" = "paleturquoise3", "Second" = "turquoise4", "Third or booster" = "#00413d"), labels = c("First", "Second", "Third or booster")) +
  facet_grid( ~ areaName) +
  scale_x_date(date_labels = "%b %y", date_breaks = "2 months") +
  ggtitle("Dorset covid vaccinations by local authority - population percentage over time") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), subtitle = "Percentage of people aged 12 and over that have received a COVID-19 vaccination") +
  xlab("Date") +
  ylab("Vaccinations") +
  scale_y_continuous(breaks = c(20, 40, 60, 80, 100), labels = scales::percent_format(scale = 1), limits = c(0,100)) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10))

covid_vaccs_percentage_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("output/daily_dorset_vaccs_percentage.png", width = 16.6, height = 8.65, units = "in")
