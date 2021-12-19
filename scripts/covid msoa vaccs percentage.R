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
  ggtext
)

vaccs_percentage_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=msoa&areaCode=E06000059&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))
vaccs_percentage_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=msoa&areaCode=E06000058&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))
vaccs_percentage_eng <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))

# MUNGE DATA ----
  
# merge datasets into one
# 1 - place datasets into a single list
vaccs_percentage_list <- list(vaccs_percentage_dor, vaccs_percentage_bcp)

# 2 - merge the datasets in the list into vaccs_combined
vaccs_percentage_combined <- merge_recurse(vaccs_percentage_list)

# keep only the columns we need, and rename the vacc event columns
vaccs_percentage_combined <- subset(vaccs_percentage_combined, select = c("date", "UtlaName", "areaName", "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage", "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage", "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"))
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage"] <- "First"
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage"] <- "Second"
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"] <- "Third or booster"

# define the date format
vaccs_percentage_combined$date = as.Date(vaccs_percentage_combined$date, "%Y-%m-%d")

# convert wide data into long
vaccs_percentage_long <- gather(vaccs_percentage_combined, event, total, First:last_col())

# get latest England figure for boosters
latest_eng <- head(vaccs_percentage_eng$cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage, 1)

# PLOT DATA ----

# create Dorset plot and geom
covid_vaccs_percentage_dorset_plot <- ggplot() +
  geom_bar(data = subset(vaccs_percentage_long, event == "First" & UtlaName == "Dorset"), aes(x = areaName, y = total), fill = "paleturquoise3", stat = "identity") +
  geom_bar(data = subset(vaccs_percentage_long, event == "Second" & UtlaName == "Dorset"), aes(x = areaName, y = total), fill = "turquoise4", stat = "identity") +
  geom_bar(data = subset(vaccs_percentage_long, event == "Third or booster" & UtlaName == "Dorset"), aes(x = areaName, y = total), fill = "#00413d", stat = "identity") +
  geom_hline(yintercept = latest_eng, linetype = "dotted", colour = "orange", size = 0.75) +
  xlab("Medium super output area (MSOA)") +
  ylab("Vaccinations") +
  scale_y_continuous(breaks = c(20, 40, 60, 80, 100), labels = scales::percent_format(scale = 1), limits = c(0,100)) +
  ggtitle("Dorset covid vaccinations by MSOA - population uptake percentage") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), subtitle = "Percentage of people aged 12 and over that have received a <span style='color:paleturquoise3;'><b>first</b></span>, <span style='color:turquoise4;'><b>second</b></span> or <span style='color:#00413d;'><b>third or booster</b></span> COVID-19 vaccination in the <span style='color:green4;'><b>Dorset Council</b></span> area, shown by MSOA.<br> The <span style='color:orange;'><b>orange</b></span> line indicates the percentage uptake for the third or booster vaccination in England.") +
  theme_base() +
  theme(
    axis.text.x = element_text(angle = 60, size = 8, hjust = 1),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10),
    legend.text = element_text(size = 12),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12))

covid_vaccs_percentage_dorset_plot

# create BCP plot and geom
covid_vaccs_percentage_bcp_plot <- ggplot() +
  geom_bar(data = subset(vaccs_percentage_long, event == "First" & UtlaName == "Bournemouth, Christchurch and Poole"), aes(x = areaName, y = total), fill = "paleturquoise3", stat = "identity") +
  geom_bar(data = subset(vaccs_percentage_long, event == "Second" & UtlaName == "Bournemouth, Christchurch and Poole"), aes(x = areaName, y = total), fill = "turquoise4", stat = "identity") +
  geom_bar(data = subset(vaccs_percentage_long, event == "Third or booster" & UtlaName == "Bournemouth, Christchurch and Poole"), aes(x = areaName, y = total), fill = "#00413d", stat = "identity") +
  geom_hline(yintercept = latest_eng, linetype = "dotted", colour = "orange", size = 0.75) +
  xlab("Medium super output area (MSOA)") +
  ylab("Vaccinations") +
  scale_y_continuous(breaks = c(20, 40, 60, 80, 100), labels = scales::percent_format(scale = 1), limits = c(0,100)) +
  ggtitle("BCP covid vaccinations by MSOA - population uptake percentage") +
  labs(caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), subtitle = "Percentage of people aged 12 and over that have received a <span style='color:paleturquoise3;'><b>first</b></span>, <span style='color:turquoise4;'><b>second</b></span> or <span style='color:#00413d;'><b>third or booster</b></span> COVID-19 vaccination in the <span style='color:magenta4;'><b>BCP Council</b></span> area, shown by MSOA.<br> The <span style='color:orange;'><b>orange</b></span> line indicates the percentage uptake for the third or booster vaccination in England.") +
  theme_base() +
  theme(
    axis.text.x = element_text(angle = 60, size = 8, hjust = 1),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10),
    legend.text = element_text(size = 12),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12))

covid_vaccs_percentage_bcp_plot

# save to daily file
ggsave("output/vaccs_percentage_msoa_dorset.png", plot = covid_vaccs_percentage_dorset_plot, width = 16.6, height = 8.65, units = "in")
ggsave("output/vaccs_percentage_msoa_bcp.png", plot = covid_vaccs_percentage_bcp_plot, width = 16.6, height = 8.65, units = "in")
