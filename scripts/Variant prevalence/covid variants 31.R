# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# set technical briefing spreadsheet path
sheet_path <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1039942/Variants-of-concern-technical-briefing-31-data-england_10_Dec-FINAL.xlsx"

# set plot title
plot_subtitle <- "Variant prevalence for all England available sequenced cases from 1 February 2021 as of 6 December 2021"

# set plot caption
plot_caption <- "Data from UK Health Security Agency technical briefing 31 (gateway number GOV-10547)."

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  httr,
  readxl,
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

GET(sheet_path, write_disk("Variants-of-concern-technical-briefing-31-data-england_10_Dec-FINAL.xlsx", overwrite = TRUE))

# Import raw data from Excel
covid_variant_data <- read_excel("Variants-of-concern-technical-briefing-31-data-england_10_Dec-FINAL.xlsx", sheet = "Fig2", skip = 2) 

# MUNGE DATA ----

# set the date format
covid_variant_data$week = as.Date(covid_variant_data$week, "%Y-%m-%d")

# convert wide data to long
covid_variant_data <- gather(covid_variant_data, variant, case_prevelance, "Omicron":last_col())

# PLOT DATA ----

# create plot and geom
covid_variant_plot <- ggplot() +
  # plot data in a stacked format
  geom_area(data = covid_variant_data, aes(x = week, y = case_prevelance, group = variant, fill = variant), position = "stack") +
  # scale settings
  scale_fill_manual(name = "Variant", values = as.vector(tableau20(19))) +
  scale_x_date(date_labels = "%b %y", date_breaks = "1 month") +
  # axis settings
  xlab("Month") +
  ylab("Case prevelance percentage") +
  # titles
  ggtitle("Covid variant prevalence in England") +
  labs(caption = paste0(plot_caption," Plotted", Sys.time(), sep = " "), subtitle = paste0(plot_subtitle)) +
  # set theme
  theme_base() +
  theme(
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10))

covid_variant_plot  

# save to daily file
ggsave("output/england_variants.png", width = 16.6, height = 8.65, units = "in")
