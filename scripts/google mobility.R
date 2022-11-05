# SET COMMON VARIABLES ----
  
# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

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

# DOWNLOAD DATA ----

# set mobility reports zipfile path
zip_path <- "https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip"

# set downloaded file path and name for downloaded data
file_name <- "devel/Region_Mobility_Report_CSVs.zip"

# download the mobility report zipfile
GET(zip_path, write_disk(file_name, overwrite = TRUE))

# extract the GB data for 2021
unzip(file_name, files = c("2022_GB_Region_Mobility_Report.csv", "2021_GB_Region_Mobility_Report.csv", "2020_GB_Region_Mobility_Report.csv"), overwrite = TRUE, exdir = "./devel/")

# IMPORT DATA ----

# import GB data files
mobility2020 <- read.csv("devel/2020_GB_Region_Mobility_Report.csv")
mobility2021 <- read.csv("devel/2021_GB_Region_Mobility_Report.csv")
mobility2022 <- read.csv("devel/2022_GB_Region_Mobility_Report.csv")

# manually read in lockdown start and end
# data from https://www.instituteforgovernment.org.uk/charts/uk-government-coronavirus-lockdowns
# and https://commonslibrary.parliament.uk/research-briefings/cbp-9068/
# xmin denotes lockdown start, xmax denotes lockdown end
lockdowns <- data.frame(
  xmin = c(as.Date(c("2020-03-23")), as.Date(c("2020-11-05")), as.Date(c("2021-01-06"))),
  xmax = c(as.Date(c("2020-07-04")), as.Date(c("2020-12-02")), as.Date(c("2021-03-29"))),
  ymin = c(-Inf, -Inf, -Inf),
  ymax = c(Inf, Inf, Inf)
)

# other restrictions
restrictions <- data.frame(
  xmin = c(as.Date(c("2021-12-08"))),
  xmax = c(as.Date(c("2022-01-27"))),
  ymin = c(-Inf),
  ymax = c(Inf)
)

# MUNGE DATA ----
  
# merge datasets into one
# 1 - place datasets into a single list
mobility_list <- list(mobility2020, mobility2021, mobility2022)

# 2 - merge the datasets in the list into vaccs_combined
mobility_combined <- merge_recurse(mobility_list)

# define the date format
mobility_combined$date = as.Date(mobility_combined$date, "%Y-%m-%d")

# filter only the Dorset data
mobility_combined <- mobility_combined %>%
  filter(sub_region_1 == "Dorset" & sub_region_2 == "")

# calculate seven day rolling average
mobility_combined <- mobility_combined %>%
  mutate(ret_av = rollmean(retail_and_recreation_percent_change_from_baseline, k = 7, fill = NA)) %>%
  mutate(gro_av = rollmean(grocery_and_pharmacy_percent_change_from_baseline, k = 7, fill = NA)) %>%
  mutate(par_av = rollmean(parks_percent_change_from_baseline, k = 7, fill = NA)) %>%
  mutate(tra_av = rollmean(transit_stations_percent_change_from_baseline, k = 7, fill = NA)) %>%
  mutate(wor_av = rollmean(workplaces_percent_change_from_baseline, k = 7, fill = NA)) %>%
  mutate(res_av = rollmean(residential_percent_change_from_baseline, k = 7, fill = NA))
  

# remove the columns we don't need
mobility_combined <- subset(mobility_combined, select = c("date", "sub_region_2", "ret_av", "gro_av", "par_av", "tra_av", "wor_av", "res_av"))

# rename the activity columns
names(mobility_combined)[names(mobility_combined) == "ret_av"] <- "Retail and recreation"
names(mobility_combined)[names(mobility_combined) == "gro_av"] <- "Grocery and pharmacy"
names(mobility_combined)[names(mobility_combined) == "par_av"] <- "Parks"
names(mobility_combined)[names(mobility_combined) == "tra_av"] <- "Public transport hubs"
names(mobility_combined)[names(mobility_combined) == "wor_av"] <- "Workplace"
names(mobility_combined)[names(mobility_combined) == "res_av"] <- "Residential"

# elongate the data
mobility_long <- gather(mobility_combined, activity, percent_change_from_baseline, "Retail and recreation":last_col(), na.rm = FALSE, convert = FALSE)

# restrict the dates if we want
# mobility_long <- subset(mobility_long, date>today() - months(12))



# PLOT DATA ----

# create plot and geom
mobility_plot <- ggplot() +
  # shaded areas to denote lockdowns
  geom_rect(
    data = lockdowns,
    fill = "lightsteelblue1", alpha = 0.5,
    aes(
    xmin = xmin,
    xmax = xmax,
    ymin = ymin,
    ymax = ymax
    )
  ) +
  # shaded areas to denote other restrictions
  geom_rect(
    data = restrictions,
    fill = "thistle2", alpha = 0.5,
    aes(
      xmin = xmin,
      xmax = xmax,
      ymin = ymin,
      ymax = ymax
    )
  ) +
  # grey line to indicate baseline
  geom_hline(yintercept = 0, colour = "black") +
  # main data plot
  geom_area(data = mobility_long, aes(x = date, y = percent_change_from_baseline), size = 0.75, colour = "springgreen4", fill = "#94d3b2", position = "stack") +
  # text annotations to indicate lockdowns and restrictions
  # x value takes the start date from the lockdowns dataframe and adds twelve for positioning
  annotate("text", x = lockdowns$xmin[1]+12, y = 250, label = "Lockdown 1", size = 2.5, colour = "darkblue", fontface = "bold", angle = 90) +
  annotate("text", x = lockdowns$xmin[2]+12, y = 250, label = "Lockdown 2", size = 2.5, colour = "darkblue", fontface = "bold", angle = 90) +
  annotate("text", x = lockdowns$xmin[3]+12, y = 250, label = "Lockdown 3", size = 2.5, colour = "darkblue", fontface = "bold", angle = 90) +
  annotate("text", x = restrictions$xmin[1]+12, y = 250, label = "Plan B", size = 2.5, colour = "violetred4", fontface = "bold", angle = 90) +
  # facet by activity
  facet_wrap(~ activity) +
  # set scales
  scale_x_date(date_labels = "%b %y", date_breaks = "3 months") +
  scale_y_continuous(breaks = c(-50, 0, 50, 100, 150, 200, 250, 300)) +
  # set axis labels
  xlab("Date") +
  ylab("Percentage change") +
  # set title and subtitle
  ggtitle("We're moving around in Dorset differently due to covid-19") +
  labs(caption = paste("Data from Google community mobility reports / https://www.google.com/covid19/mobility. Lockdown dates from the Insitute for Government. Plotted", Sys.time(), sep = " ", "\nData plot by Andrew Harrison / https://aharriso11.github.io/dorset_covid"), subtitle = "How visits and lengths of stay at different places change compared to a pre-covid baseline (3rd Jan - 6th Feb 2020), calculated from Google account users who have opted in to location history features.<br>Shaded light blue areas indicate periods of national restrictions.") +
  # set theme and customisations
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

# run the plot
mobility_plot

# save to file
ggsave("output/mobility.png", width = 16.6, height = 8.65, units = "in")
