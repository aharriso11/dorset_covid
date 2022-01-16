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
  ggalt,
  fuzzyjoin
)

# DEFINE QUERY FILTERS AND STRUCTURE ----

# query filter for England
filter_eng <- c(
  'areaType=nation',
  'areaCode=E92000001'
)

# query filter for SW
filter_rsw <-c(
  'areaType=nhsRegion',
  'areaCode=E40000006'
)

# query filter for RBD
filter_rbd <-c(
  'areaType=nhsTrust',
  'areaCode=RBD'
)

# query filter for R0D
filter_r0d <-c(
  'areaType=nhsTrust',
  'areaCode=R0D'
)

# data structure for the API call
df_structure <- c(date = "date",
                  areaName = "areaName",
                  areaCode = "areaCode",
                  hospitalCases = "hospitalCases",
                  newAdmissions = 'newAdmissions'
)

# IMPORT DATA ----

# England
df_eng <- get_data(
  filters = filter_eng,
  structure = df_structure
)

# south west
df_rsw <- get_data(
  filters = filter_rsw,
  structure = df_structure
)

# dorset county hospital
df_rbd <- get_data(
  filters = filter_rbd,
  structure = df_structure
)

# university hospitals dorset
df_r0d <- get_data(
  filters = filter_r0d,
  structure = df_structure
)

# CREATE SUPPLEMENTARY DATA----

# waves dataframe - as a tibble to allow use with fuzzy_join below
df_waves <- tibble(
  start = c(as.Date(c("2020-03-01")), as.Date(c("2020-09-01")), as.Date(c("2021-05-01"))),
  end = c(as.Date(c("2020-08-31")), as.Date(c("2021-04-30")), as.Date(today())),
  Wave = c("Wave 1", "Wave 2", "Wave 3")
)

# PROCESS DATA ----

# merge datasets into one
# 1 - place datasets into a single list
df_list <- list(df_eng, df_rsw, df_rbd, df_r0d)

# 2 - merge the datasets in the list into vaccs_combined
df_combined <- merge_recurse(df_list)

# define the date format
df_combined$date = as.Date(df_combined$date, "%Y-%m-%d")

# calculate averages
df_combined <- df_combined %>%
  group_by(areaCode) %>%
  mutate(hospitalCasesA = rollmean(hospitalCases, k = 7, fill = NA)) %>%
  mutate(newAdmissionsA = rollmean(newAdmissions, k = 7, fill = NA))

# convert to tibble to permit the fuzzy join below
as_tibble(df_combined)

# use fuzzy join to lookup the date for each observation against the date ranges in df_waves
df_combined <- fuzzy_left_join(
  df_combined, df_waves,
  by = c(
    "date" = "start",
    "date" = "end"
  ),
  match_fun = list(`>=`, `<=`)
) %>%
  select(areaCode, areaType, areaName, date, hospitalCasesA, newAdmissionsA, Wave)

df_combined <- df_combined %>%
  filter(!is.na(newAdmissionsA) & !is.na(hospitalCasesA))

df_latest <- df_combined %>%
  group_by(areaCode) %>%
  slice(which.max(date))

# EARLY EXPERIMENT WITH BASE PLOT----

# png("hosp phase.png", width = 675, height = 675)

# plot(
#  subset(df_combined, areaCode=="E92000001", select = newAdmissionsA), 
#  subset(df_combined, areaCode=="E92000001", select = hospitalCasesA),
#  pch = 1,
#  cex = 1,
#  col = wave_colours[df_c$name],
#  xlab = "New admissions\nX denotes latest plot",
#  ylab = "Cases in hospital",
#  main = "Phase plot of new admissions compared to hospital cases"
# )

# points(x1,y1,col="black",pch=4,cex=2,lwd=3)

# legend(x = "right",
       ## Specify the group names.
#       legend = c("Wave 1", "Wave 2", "Wave 3"),
       ## And the colors of the dots.
#       col = wave_colours,
       ## And the shape of the dots.
#       pch = 1, cex = 1, bty = "n")

# dev.off()

# PLOT DATA----

df_plot <- ggplot() +
  # main data
  geom_point(data = df_combined, aes(x = newAdmissionsA, y = hospitalCasesA, colour = Wave), shape = 1, size = 2) +
  # latest data (black spot)
  geom_point(data = df_latest, aes(x = newAdmissionsA, y = hospitalCasesA), colour = "black", shape = 16, size = 2) +
  # faceting
  facet_wrap( ~ areaName, scales = "free") +
  # scale colours
  scale_colour_manual(name = "Wave", values = c("Wave 1" = "red", "Wave 2" = "blue", "Wave 3" = "limegreen")) +
  # axis settings
  xlab("New admissions to hospital with covid-19") +
  ylab("Cases of people in hospital with covid-19") +
  # set title and subtitle
  ggtitle("Comparing covid hospital admissions with cases in hospital") +
  labs(caption = paste("Data from the UK Health Security Agency. Plotted", Sys.time(), sep = " ", "\nData plot by Andrew Harrison / https://aharriso11.github.io/dorset_covid, and inspired by @bristoliver"), 
       subtitle = "The daily number of new admissions to hospital of patients with covid-19, compared with the daily number of confirmed covid-19 patients in hospital.<br>
       If the black dot goes up, the number of people in hospital with covid-19 is rising. If the black dot moves to the right, the number of people being admitted to hospital with covid-19 is rising.<br>
       <b><span style='color:red;'>Wave 1</span></b> ran from 1st March 2020 to 31st August 2020. <b><span style='color:blue;'>Wave 2</span></b> ran from 1st September 2020 to 30th April 2021. <b><span style='color:limegreen;'>Wave 3</span></b> began on 1st May 2021 and is the current wave."
       ) +
    # set theme and customisations
  theme_base() +
  theme(
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 8),
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 8),
    strip.text.y = element_text(size = 9.5),
    strip.text.x = element_text(size = 9.5, face = "bold"))

# run plot
df_plot

# save to daily file
ggsave("output/hosp_phase.png", width = 16.6, height = 8.65, units = "in")
