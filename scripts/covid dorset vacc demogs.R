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
  data.table,
  ggthemes,
  pals
)

# IMPORT DATASETS ----

vaccs_demog_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E06000059&metric=vaccinationsAgeDemographics&format=csv"))
vaccs_demog_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&areaCode=E06000058&metric=vaccinationsAgeDemographics&format=csv"))

# MUNGE DATA ----

# merge datasets into one
# 1 - place datasets into a single list
vaccs_demog_list <- list(vaccs_demog_dor, vaccs_demog_bcp)

# 2 - merge the datasets in the list into vaccs_combined
vaccs_demog_combined <- merge_recurse(vaccs_demog_list)

# keep only the columns we need, and rename the vacc event columns
vaccs_demog_combined <- subset(vaccs_demog_combined, select = c("areaName", "date", "age", "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage", "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage", "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"))
names(vaccs_demog_combined)[names(vaccs_demog_combined) == "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage"] <- "First"
names(vaccs_demog_combined)[names(vaccs_demog_combined) == "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage"] <- "Second"
names(vaccs_demog_combined)[names(vaccs_demog_combined) == "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"] <- "Third or booster"

# define the date format
vaccs_demog_combined$date = as.Date(vaccs_demog_combined$date, "%Y-%m-%d")

# convert wide data into long
vaccs_demog_long <- gather(vaccs_demog_combined, event, total, First:last_col())

# PLOT DATA ----

# create plot and geom
vaccs_demog_plot <- ggplot() +
  geom_path(data = subset(vaccs_demog_long), aes(x = date, y = total, colour = age)) +
  facet_grid(rows = vars(areaName), cols = vars(event)) +
  scale_x_date(date_labels = "%b %y", date_breaks = "2 months") +
  scale_colour_manual(name = "Age", values = as.vector(kovesi.isoluminant_cgo_70_c39(17))) +
  xlab("Date") +
  ylab("Percentage uptake") +
  ggtitle("Dorset covid vaccinations - uptake percentage age breakdown") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), subtitle = "Percentage of people aged 12 and over that have received COVID-19 vaccinations in Dorset and BCP, broken down by age groups.") +
  theme_base() +
  theme(
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10),
    legend.text = element_text(size = 12),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 8),
    strip.text.y = element_text(size = 9.5))

vaccs_demog_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("output/vaccinations_age.png", width = 16.6, height = 8.65, units = "in")
