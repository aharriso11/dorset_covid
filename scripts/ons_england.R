# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

# install the UKHSA covid-19 R SDK
# remotes::install_github("publichealthengland/coronavirus-dashboard-api-R-sdk")
# library(ukcovid19)

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
  janitor
)

# OBTAIN DATA ----

# set url for web page containing link to the ONS survey data
page <- read_html(url("https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/conditionsanddiseases/datasets/coronaviruscovid19infectionsurveydata/2022"))

# extract all the URLs from the page
urls <- page %>%
  html_nodes("a") %>%
  html_attr("href")

# extract all the link names from the page
# not needed for the live script but useful for troubleshooting
links <- page %>%
  html_nodes("a") %>%
  html_text()

# merge these two into a data frame
df_links <- data.frame(
  links = links, 
  urls = urls, 
  stringsAsFactors = FALSE)

# pass the data frame containing the links through two filters to get the url for the survey data
# we figure this out through trial, error and mk 1 eyeball
url <- df_links %>%
  filter(str_detect(urls, "coronaviruscovid19infectionsurveydata/2022/2022"))

# because the ONS website uses relative paths for its links we must create an absolute path
downloadurl <- paste("https://www.ons.gov.uk", url$urls[1], sep="")

# download the survey file
GET(downloadurl, write_disk("devel/onslatest.xlsx", overwrite = TRUE))

# REPORT DATES ----
df_cover <- read_excel("devel/onslatest.xlsx", sheet = "Cover sheet", skip = 10)
date_publication <- strsplit((as.character(df_cover[7, ])), split = ": ")[[1]][[2]]
date_next <- strsplit((as.character(df_cover[8, ])), split = ": ")[[1]][[2]]

# ENGLAND ----

# import data from downloaded file
df_eng_daily <- read_excel("devel/onslatest.xlsx", sheet = "1b", skip = 4)

# convert dates from numeric to Gregorian format
df_eng_daily$Date <- convertToDate(df_eng_daily$Date)

# subset the modelled number of people and remove empty rows left from the import
df_eng_daily_number <- 
  subset(df_eng_daily, select = c("Date", "Modelled number of people testing positive for COVID-19", "95% Lower credible interval...6", "95% Upper credible interval...7")) %>%
  remove_empty("rows")

# Rename columns
names(df_eng_daily_number)[names(df_eng_daily_number) == "95% Lower credible interval...6"] <- "ymin"
names(df_eng_daily_number)[names(df_eng_daily_number) == "95% Upper credible interval...7"] <- "ymax"

# get title dates
date_first <- format(head(df_eng_daily_number$Date, 1), "%d %B")
date_last <- format(tail(df_eng_daily_number$Date, 1), "%d %B")

# convert wide data into long
df_long <- gather(df_eng_daily_number, event, total, -c(Date))

st1 <- paste("The modelled number of people in England testing positive for covid-19, from the ONS covid-19 infection survey.<br>
       The lighter shaded area shows the <b>confidence interval</b> within which the actual number of infections might fall.<br>
       This dataset was produced on <b>", date_publication, "</b> and covers dates between ", date_first, " and ", date_last, ". The next update will be on <b>", date_next, "</b>.", sep = "")

# plot and geoms
df_plot_eng <- ggplot() +
  # Plot confidence interval as a ribbon
  geom_ribbon(data = df_eng_daily_number, aes(x = Date, ymin = ymin, ymax = ymax), fill = "thistle1") +
  # plot the modelled number and upper and lower intervals as xps lines
  geom_xspline(data = subset(df_long, event=="Modelled number of people testing positive for COVID-19"), aes(x = Date, y = total), stat = "xspline", size = 1.25, colour = "red4") +
  geom_xspline(data = subset(df_long, event=="ymin"), aes(x = Date, y = total), stat = "xspline", colour = "thistle3") +
  geom_xspline(data = subset(df_long, event=="ymax"), aes(x = Date, y = total), stat = "xspline", colour = "thistle3") +
  # scale settings
  scale_x_date(date_labels = "%d %b", date_breaks = "3 days") +
  scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6, accuracy = 0.1), position = "right") +
  # axis settings
  xlab("Date") +
  ylab("") +
  # set title and subtitle
  ggtitle("Modelled daily rates of the percentage of the population testing positive for covid-19 in England") +
  labs(caption = paste("Data from the Office for National Statistics. Plotted", Sys.time(), sep = " ", "\nData plot by Andrew Harrison / https://aharriso11.github.io/dorset_covid"), 
       subtitle = paste0(st1)) +
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
    strip.text.x = element_text(size = 12),
    strip.text.y = element_text(size = 12)
  )

# generate the plot
df_plot_eng

# save the plot
ggsave("output/ons_england.png", plot = df_plot_eng, width = 16.6, height = 8.65, units = "in")

# REGIONS ----

# read in region headers as a vector
region_headers <- c(
  "Date",
  "North East_Modelled % testing positive for COVID-19",
  "North East_95% Lower credible interval pc",
  "North East_95% Upper credible interval pc",
  "North East_Modelled number of people testing positive for COVID-19",
  "North East_95% Lower credible interval nm",
  "North East_95% Upper credible interval nm",
  "North East_Modelled ratio of people testing positive for COVID-19",
  "North East_95% Lower credible interval ra",
  "North East_95% Upper credible interval ra",
  "North West_Modelled % testing positive for COVID-19",
  "North West_95% Lower credible interval pc",
  "North West_95% Upper credible interval pc",
  "North West_Modelled number of people testing positive for COVID-19",
  "North West_95% Lower credible interval nm",
  "North West_95% Upper credible interval nm",
  "North West_Modelled ratio of people testing positive for COVID-19",
  "North West_95% Lower credible interval ra",
  "North West_95% Upper credible interval ra",
  "Yorkshire and the Humber_Modelled % testing positive for COVID-19",
  "Yorkshire and the Humber_95% Lower credible interval pc",
  "Yorkshire and the Humber_95% Upper credible interval pc",
  "Yorkshire and the Humber_Modelled number of people testing positive for COVID-19",
  "Yorkshire and the Humber_95% Lower credible interval nm",
  "Yorkshire and the Humber_95% Upper credible interval nm",
  "Yorkshire and the Humber_Modelled ratio of people testing positive for COVID-19",
  "Yorkshire and the Humber_95% Lower credible interval ra",
  "Yorkshire and the Humber_95% Upper credible interval ra",
  "East Midlands_Modelled % testing positive for COVID-19",
  "East Midlands_95% Lower credible interval pc",
  "East Midlands_95% Upper credible interval pc",
  "East Midlands_Modelled number of people testing positive for COVID-19",
  "East Midlands_95% Lower credible interval nm",
  "East Midlands_95% Upper credible interval nm",
  "East Midlands_Modelled ratio of people testing positive for COVID-19",
  "East Midlands_95% Lower credible interval ra",
  "East Midlands_95% Upper credible interval ra",
  "West Midlands_Modelled % testing positive for COVID-19",
  "West Midlands_95% Lower credible interval pc",
  "West Midlands_95% Upper credible interval pc",
  "West Midlands_Modelled number of people testing positive for COVID-19",
  "West Midlands_95% Lower credible interval nm",
  "West Midlands_95% Upper credible interval nm",
  "West Midlands_Modelled ratio of people testing positive for COVID-19",
  "West Midlands_95% Lower credible interval ra",
  "West Midlands_95% Upper credible interval ra",
  "East of England_Modelled % testing positive for COVID-19",
  "East of England_95% Lower credible interval pc",
  "East of England_95% Upper credible interval pc",
  "East of England_Modelled number of people testing positive for COVID-19",
  "East of England_95% Lower credible interval nm",
  "East of England_95% Upper credible interval nm",
  "East of England_Modelled ratio of people testing positive for COVID-19",
  "East of England_95% Lower credible interval ra",
  "East of England_95% Upper credible interval ra",
  "London_Modelled % testing positive for COVID-19",
  "London_95% Lower credible interval pc",
  "London_95% Upper credible interval pc",
  "London_Modelled number of people testing positive for COVID-19",
  "London_95% Lower credible interval nm",
  "London_95% Upper credible interval nm",
  "London_Modelled ratio of people testing positive for COVID-19",
  "London_95% Lower credible interval ra",
  "London_95% Upper credible interval ra",
  "South East_Modelled % testing positive for COVID-19",
  "South East_95% Lower credible interval pc",
  "South East_95% Upper credible interval pc",
  "South East_Modelled number of people testing positive for COVID-19",
  "South East_95% Lower credible interval nm",
  "South East_95% Upper credible interval nm",
  "South East_Modelled ratio of people testing positive for COVID-19",
  "South East_95% Lower credible interval ra",
  "South East_95% Upper credible interval ra",
  "South West_Modelled % testing positive for COVID-19",
  "South West_95% Lower credible interval pc",
  "South West_95% Upper credible interval pc",
  "South West_Modelled number of people testing positive for COVID-19",
  "South West_95% Lower credible interval nm",
  "South West_95% Upper credible interval nm",
  "South West_Modelled ratio of people testing positive for COVID-19",
  "South West_95% Lower credible interval ra",
  "South West_95% Upper credible interval ra"
)

# import data from downloaded file and replace the headers
df_region_daily <- read_excel("devel/onslatest.xlsx", sheet = "1f", skip = 6, col_names = region_headers)

# remove the last seven rows which are not useful
df_region_daily <- head(df_region_daily, -7)

# convert dates from numeric to Gregorian format
df_region_daily$Date <- convertToDate(df_region_daily$Date)

# convert data from wide to long and separate out region and metric columns
df_region_daily <- df_region_daily %>%
  gather(METRIC, VALUE, -c("Date")) %>%
  separate(METRIC, into = c("REGION", "METRIC"), sep = "_")

# subset the modelled daily case numbers
df_region_daily_numbers <- df_region_daily %>%
  filter(METRIC %in% c("Modelled number of people testing positive for COVID-19", "95% Lower credible interval nm", "95% Upper credible interval nm"))

# convert values to numeric
df_region_daily_numbers$VALUE <- as.numeric(as.character(df_region_daily_numbers$VALUE))

# spread region numbers to give us separated figures for ribbon plot
df_region_daily_numbers_wide <- df_region_daily_numbers %>%
  pivot_wider(names_from = METRIC, values_from = VALUE)

# get title dates
date_first <- format(head(df_region_daily_numbers$Date, 1), "%d %B")
date_last <- format(tail(df_region_daily_numbers$Date, 1), "%d %B")

# Rename columns
names(df_region_daily_numbers_wide)[names(df_region_daily_numbers_wide) == "95% Lower credible interval nm"] <- "ymin"
names(df_region_daily_numbers_wide)[names(df_region_daily_numbers_wide) == "95% Upper credible interval nm"] <- "ymax"

st2 <- paste("The modelled number of people in English regions testing positive for covid-19, from the ONS covid-19 infection survey.<br>
       The lighter shaded area shows the <b>confidence interval</b> within which the actual number of infections might fall.<br>
       This dataset was produced on <b> ", date_publication, " </b> and covers dates between ", date_first, " and ", date_last, ". The next update will be on <b>", date_next, "</b>.", sep = "")

# plot and geoms
df_plot_region_numbers <- ggplot() +
  # Plot confidence interval as a ribbon
  geom_ribbon(data = df_region_daily_numbers_wide, aes(x = Date, ymin = ymin, ymax = ymax), fill = "thistle1") +
  # plot the modelled number and upper and lower intervals as xps lines
  geom_xspline(data = subset(df_region_daily_numbers, METRIC == "Modelled number of people testing positive for COVID-19"), aes(x = Date, y = VALUE), stat = "xspline", size = 1.25, colour = "red4") +
  geom_xspline(data = subset(df_region_daily_numbers, METRIC == "95% Lower credible interval nm"), aes(x = Date, y = VALUE), stat = "xspline", colour = "thistle3") +
  geom_xspline(data = subset(df_region_daily_numbers, METRIC == "95% Upper credible interval nm"), aes(x = Date, y = VALUE), stat = "xspline", colour = "thistle3") + 
  # facet by area name
  facet_wrap( ~ REGION, ncol = 3) +
  # scale settings
  scale_x_date(date_labels = "%d %b", date_breaks = "7 days") +
  scale_y_continuous(labels = comma) +
  # axis settings
  xlab("Date") +
  ylab("Modelled number of people testing positive for covid-19")+ 
  # set title and subtitle
  ggtitle("Modelled daily rates of the percentage of the population testing positive for covid-19 in English regions") +
  labs(caption = paste("Data from the Office for National Statistics. Plotted", Sys.time(), sep = " ", "\nData plot by Andrew Harrison / https://aharriso11.github.io/dorset_covid"), 
       subtitle = paste0(st2)) +
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
    strip.text.x = element_text(size = 12),
    strip.text.y = element_text(size = 12)
  )

# generate the plot
df_plot_region_numbers

# save the plot
ggsave("output/ons_regions.png", plot = df_plot_region_numbers, width = 16.6, height = 8.65, units = "in")
