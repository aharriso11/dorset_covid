# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

# install the UKHSA covid-19 R SDK
remotes::install_github("publichealthengland/coronavirus-dashboard-api-R-sdk")
library(ukcovid19)

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  httr,
  readxl,
  readODS,
  tidyverse,
  zoo,
  data.table,
  scales,
  glue,
  ggtext,
  ggthemes,
  pals,
  utils,
  reshape,
  lubridate,
  rvest,
  stringr,
  openxlsx,
  ggalt
)

# IMPORT DATA ----

# query filter for Dorset County Hospital
filter_rbd <- c(
  'areaType=nhsTrust',
  'areaCode=RBD'
)

# query filter for University Hospitals Dorset
filter_r0d <- c(
  'areaType=nhsTrust',
  'areaCode=R0D'
)

# data structure for the API call
df_structure <- c(date = "date",
  areaName = "areaName",
  areaCode = "areaCode",
  hospitalCases = "hospitalCases",
  covidOccupiedMVBeds = "covidOccupiedMVBeds",
  newAdmissions = 'newAdmissions'
)

# call RBD (DCH) data
df_rbd <- get_data(
  filters = filter_rbd, 
  structure = df_structure
)

# call R0D (UHD) data
df_r0d <- get_data(
  filters = filter_r0d,
  structure = df_structure
)

# CONVOLUTED IMPORT FOR NHS ENGLAND DATA ----
# the url for the spreadsheet containing the deaths data changes every week

# set url for web page containing link to the deaths data
deathpage <- read_html(url("https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-deaths/"))

# extract all the URLs from the page
urls <- deathpage %>%
  html_nodes("a") %>%
  html_attr("href")
  
# extract all the link names from the page
# not needed for the live script but useful for troubleshooting
links <- deathpage %>%
  html_nodes("a") %>%
  html_text()

# merge these two into a data frame
df_links <- data.frame(
  links = links, 
  urls = urls, 
stringsAsFactors = FALSE)

# pass the data frame containing the links through two filters to get the url for the deaths data
# we figure this out through trial, error and mk 1 eyeball
deathurl <- df_links %>%
  filter(str_detect(urls, "COVID-19-total-announced-deaths")) %>%
  filter(str_detect(urls, "supplementary", negate = TRUE))

# download the file
GET(deathurl$urls[1], write_disk("devel/nhsdeaths.xlsx", overwrite = TRUE))

df_deaths <- read_excel("devel/nhsdeaths.xlsx", sheet = "Tab4a Deaths by trust", skip = 16)


# PROCESS DATA - HOSPITAL ACTIVITY ----

# merge datasets into one
# 1 - place datasets into a single list
df_list <- list(df_r0d, df_rbd)

# 2 - merge the datasets in the list into df_combined
df_combined <- merge_recurse(df_list)

# define the date format
df_combined$date = as.Date(df_combined$date, "%Y-%m-%d")

# convert wide data into long
# df_long <- gather(df_combined, event, total, hospitalCases:last_col())
df_long <- gather(df_combined, event, total, -c(areaCode, areaType, areaName, date))

# restrict to twelve weeks
df_long <- subset(df_long, date > today() - weeks(12))


# PROCESS DATA - HOSPITAL DEATHS ----

# Delete unwanted columns from hosp_deaths that break the filter below
df_deaths <- df_deaths[-c(2, 3)]

# Delete the top three rows
df_deaths <- df_deaths[-1,]
df_deaths <- df_deaths[-1,]
df_deaths <- df_deaths[-1,]

# Delete the bottom four rows
df_deaths <- head(df_deaths, -4)

# Name the date column
names(df_deaths)[names(df_deaths) == "...1"] <- "date"

# convert dates from numeric to Gregorian format
df_deaths$date <- convertToDate(df_deaths$date)

# Limit data to just R0D and RBD
df_deaths <- subset(df_deaths, select = c("date", "R0D", "RBD"))

# elongate deaths data
df_deaths <- gather(df_deaths, areaCode, total, "R0D", "RBD", na.rm = FALSE, convert = FALSE)

# add and rearrange columns to mirror the layout of df_long
df_deaths$areaType <- "nhsTrust"
df_deaths$event <- "Deaths"

df_deaths <- df_deaths %>%
  mutate(areaName = case_when(areaCode == "RBD" ~ "Dorset County Hospital NHS Foundation Trust",
                              areaCode == "R0D" ~ "University Hospitals Dorset NHS Foundation Trust"))

df_deaths <- subset(df_deaths, select = c("areaCode", "areaType", "areaName", "date", "event", "total"))

# restrict to twelve weeks
df_deaths <- subset(df_deaths, date > today() - weeks(12))

# merge datasets into one
# 1 - place datasets into a single list
df_list_2 <- list(df_long, df_deaths)

# 2 - merge the datasets in the list into vaccs_combined
df_merged_activity_and_deaths <- merge_recurse(df_list_2)

# set the total column as an integer
df_merged_activity_and_deaths$total <- as.integer(df_merged_activity_and_deaths$total)

# PLOT DATA ----

# RBD plot and geoms
rbd_plot2 <- ggplot(data = df_merged_activity_and_deaths, aes(x = date, y = total)) +
  # Plot admissions subset as a bar chart
  geom_bar(data = subset(df_merged_activity_and_deaths, areaCode=="RBD" & event=="newAdmissions"), aes(x = date, y = total, fill = "grey67"), stat = "identity") +
  geom_bar(data = subset(df_merged_activity_and_deaths, areaCode=="RBD" & event=="Deaths"), aes(x=date,y=-total,fill="black"), stat = "identity", inherit.aes = FALSE) +
  # Plot all covid beds occupied as a line using geom_xspline to create a smoothing effect
  geom_step(data = subset(df_merged_activity_and_deaths, areaCode=="RBD" & event=="hospitalCases"), aes(colour = "turquoise4"), size = 1) +
  # Plot all mechanical ventilation covid beds occupied as a line using geom_xspline to create a smoothing effect
  geom_step(data = subset(df_merged_activity_and_deaths, areaCode=="RBD" & event=="covidOccupiedMVBeds"), aes(colour = "red4"), size = 1) +
  geom_hline(yintercept=0) +
  xlab("Date") +
  ylab("Number") +
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  scale_y_continuous(position = "right") +
  scale_fill_identity(name = "Admissions and deaths", guide = 'legend', labels = c("Deaths", "Admissions")) +
  scale_colour_manual(name = "Covid +ve beds occupied", values = c("red4" = "red4", "turquoise4" = "turquoise4"), labels = c("Mechanical ventilation", "Total beds")) +
  # set title
  ggtitle("Covid in Dorset - hospital focus - Dorset County Hospital") +
  labs(caption = paste("Data from NHS England / https://www.england.nhs.uk and UKHSA / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ", "\nData plot by Andrew Harrison / https://aharriso11.github.io/dorset_covid"), subtitle = "Admissions data is published weekly, so may be missing for more recent days") +
  theme_base() +
  theme(
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 8),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 8),
    strip.text.y = element_text(size = 9.5))

rbd_plot2

ggsave("output/hosp_rbd.png", plot = rbd_plot2, width = 16.6, height = 8.65, units = "in", device = "png")



# R0D plot and geoms

r0d_plot2 <- ggplot(data = df_merged_activity_and_deaths, aes(x = date, y = total)) +
  # Plot admissions subset as a bar chart
  geom_bar(data = subset(df_merged_activity_and_deaths, areaCode=="R0D" & event=="newAdmissions"), aes(x = date, y = total, fill = "grey67"), stat = "identity") +
  geom_bar(data = subset(df_merged_activity_and_deaths, areaCode=="R0D" & event=="Deaths"), aes(x=date,y=-total,fill="black"), stat = "identity", inherit.aes = FALSE) +
  # Plot all covid beds occupied as a line using geom_xspline to create a smoothing effect
  geom_step(data = subset(df_merged_activity_and_deaths, areaCode=="R0D" & event=="hospitalCases"), aes(colour = "turquoise4"), size = 1) +
  # Plot all mechanical ventilation covid beds occupied as a line using geom_xspline to create a smoothing effect
  geom_step(data = subset(df_merged_activity_and_deaths, areaCode=="R0D" & event=="covidOccupiedMVBeds"), aes(colour = "red4"), size = 1) +
  geom_hline(yintercept=0) +
  xlab("Date") +
  ylab("Number") +
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  scale_y_continuous(position = "right") +
  scale_fill_identity(name = "Admissions and deaths", guide = 'legend', labels = c("Deaths", "Admissions")) +
  scale_colour_manual(name = "Covid +ve beds occupied", values = c("red4" = "red4", "turquoise4" = "turquoise4"), labels = c("Mechanical ventilation", "Total beds")) +
  # set title
  ggtitle("Covid in Dorset - hospital focus - University Hospitals Dorset") +
  labs(caption = paste("Data from NHS England / https://www.england.nhs.uk and UKHSA / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ", "\nData plot by Andrew Harrison / https://aharriso11.github.io/dorset_covid"), subtitle = "Admissions data is published weekly, so may be missing for more recent days") +
  theme_base() +
  theme(
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 8),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 8),
    strip.text.y = element_text(size = 9.5))

r0d_plot2

ggsave("output/hosp_r0d.png", plot = r0d_plot2, width = 16.6, height = 8.65, units = "in", device = "png")
