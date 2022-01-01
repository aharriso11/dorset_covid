# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# set technical briefing spreadsheet path
sheet_path <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1043695/variants-of-concern-technical-briefing-33-data-england-23-december-2021.ods"

# set plot title
plot_subtitle <- "Variant prevalence for all England available sequenced cases from 31 January 2021 as of 21 December 2021"

# set plot caption
plot_caption <- "Data from UK Health Security Agency technical briefing 33 (gateway number GOV-10869)."

# set file name
file_name <- "devel/techreport33.ods"

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  httr,
  readxl,
  readODS,
  tidyr,
  ggplot2,
  dplyr,
  zoo,
  data.table,
  scales,
  glue,
  ggtext,
  ggthemes,
  pals
)

# IMPORT DATA ----

GET(sheet_path, write_disk(file_name, overwrite = TRUE))

# Import raw data from Excel
covid_variant_data <- read_ods(file_name, sheet = "Fig8B", skip = 2) 

# MUNGE DATA ----

# set the date format
covid_variant_data$spec.date = as.Date(covid_variant_data$spec.date, "%m/%d/%Y")

# convert wide data to long
# covid_variant_data <- gather(covid_variant_data, variant, case_prevelance, "Omicron":last_col())

# PLOT DATA ----

# create plot and geom
covid_variant_plot <- ggplot() +
  # plot data 
  geom_line(data = covid_variant_data, aes(x = spec.date, y = count_age, group = age.group, colour = age.group)) +
  facet_wrap( ~ variant) +
  # scale settings
  scale_colour_manual(name = "Age group", values = as.vector(tableau20(19))) +
  scale_x_date(date_labels = "%d %b", date_breaks = "1 week") +
  # axis settings
  xlab("Date") +
  ylab("Number of sequenced and genotyped cases") +
  # titles
  ggtitle("Comparison of sequenced and genotyped Delta (VOC-21APR-02) and Omicron (VOC-21NOV-01) case rate") +
  labs(caption = paste0(plot_caption," Plotted ", Sys.time(), sep = " "), subtitle = paste0(plot_subtitle)) +
  # set theme
  theme_base() +
  theme(
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10))

covid_variant_plot  

# save to daily file
ggsave("output/england_variants.png", width = 16.6, height = 8.65, units = "in")
