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
  lubridate
)

# IMPORT DATA ----

# query filter for Dorset
filter_dorset <- c(
  'areaType=utla',
  'areaCode=E06000059'
)

# query filter for BCP
filter_bcp <- c(
  'areaType=utla',
  'areaCode=E06000058'
)

# data structure for the API call
df_structure <- c(date = "date",
  areaName = "areaName",
  areaCode = "areaCode",
  changeInNewCasesBySpecimenDate = "changeInNewCasesBySpecimenDate",
  previouslyReportedNewCasesBySpecimenDate = "previouslyReportedNewCasesBySpecimenDate"
)

# call Dorset data
df_dorset <- get_data(
  filters = filter_dorset, 
  structure = df_structure
)

# call BCP data
df_bcp <- get_data(
  filters = filter_bcp,
  structure = df_structure
)

# PROCESS DATA ----

# merge datasets into one
# 1 - place datasets into a single list
df_list <- list(df_dorset, df_bcp)

# 2 - merge the datasets in the list into vaccs_combined
df_combined <- merge_recurse(df_list)

# define the date format
df_combined$date = as.Date(df_combined$date, "%Y-%m-%d")

# convert wide data into long
df_long <- gather(df_combined, event, total, -c(areaCode, areaType, areaName, date))

# filter to the last two weeks
df_long <- subset(df_long, date > today() - days(21))

# PLOT DATA ----
# create plot and geom
df_plot <- ggplot() +
  geom_bar(data = df_long, aes(x = date, y = total, fill = event), stat = "identity", position = "stack") +
  # facet by area name
  facet_grid( ~ areaName) +
  # legend settings
  scale_fill_manual(name = "Change in cases", values = c("changeInNewCasesBySpecimenDate" = "darkgoldenrod1", "previouslyReportedNewCasesBySpecimenDate" = "darkblue"), labels = c("New cases", "Existing cases")) +
  # scale settings
  scale_x_date(date_labels = "%d %b", date_breaks = "3 days") +
  scale_y_continuous(position = "right") +
  # axis settings
  xlab("Date") +
  ylab("Cases") +
  # set title and subtitle
  ggtitle("How the daily reported covid case total builds over several days") +
  labs(caption = paste("Data from the UK Health Security Agency. Plotted", Sys.time(), sep = " ", "\nData plot by Andrew Harrison / https://aharriso11.github.io/dorset_covid"), subtitle = "The numbers for covid cases by specimen date get progressively updated over about five days.") +
  # set theme
  theme_base() +
  theme(
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 8),
    legend.text = element_text(size = 12),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 8),
    strip.text.y = element_text(size = 9.5))

# build the plot
df_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("output/dorset_cases_change.png", width = 16.6, height = 8.65, units = "in")
