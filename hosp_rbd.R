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
  rjson,
  ggthemes,
  extrafont,
  tidyr,
  ggalt,
  directlabels
)

# install fonts
font_import(paths = c("~/Documents/GitHub/dorset_covid"), prompt = F)
extrafont::loadfonts()

source("covid hospital focus.R")

# RBD plot and geoms
rbd_plot <- ggplot(hosp_combined, aes(x=hdate,y=hnumber)) +
  # Plot admissions subset as a bar chart
  geom_bar(data = subset(hosp_combined, Code=="RBD" & hevent=="hospads_number"), aes(fill="gray67"), stat = "identity") + 
  geom_bar(data = subset(hosp_combined, Code=="RBD" & hevent=="death_number"), aes(x=hdate,y=-hnumber,fill="black"), stat = "identity", inherit.aes = FALSE) +
  # Plot all covid beds occupied as a line using geom_xspline to create a smoothing effect
  geom_xspline(data = subset(hosp_combined, Code=="RBD" & hevent=="totalbeds_number"), aes(colour = "turquoise4"), spline_shape = 1, size = 1) +
  # Plot all mechanical ventilation covid beds occupied as a line using geom_xspline to create a smoothing effect
  geom_xspline(data = subset(hosp_combined, Code=="RBD" & hevent=="mv_number"), aes(colour = "red4"), spline_shape = 1, size = 1) +
  geom_hline(yintercept=0) +
  xlab("Date") +
  ylab("Number") +
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  scale_y_continuous(position = "right") +
  scale_fill_identity(name = "Admissions and deaths", guide = 'legend', labels = c("Deaths", "Admissions")) +
  scale_colour_manual(name = "Covid +ve beds occupied", values = c("red4" = "red4", "turquoise4" = "turquoise4"), labels = c("Mechanical ventilation", "Total beds")) +
  # set title
  ggtitle("Covid in Dorset - hospital focus - Dorset County Hospital") +
  labs(caption = paste("Data from NHS England / https://www.england.nhs.uk. Plotted", Sys.time(), sep = " "), subtitle = "Admissions data is published weekly, so may by missing for more recent days") +
  theme_economist(base_family="Officina Sans ITC Book") +
  theme(axis.line.x = element_line(size=.5, colour = "black"),
        legend.position="right", 
        legend.direction="vertical", 
        legend.title = element_text(size = 14),
        legend.text = element_text(size = 12),
        plot.title=element_text(family="Officina Sans ITC Book", size = 24),
        plot.subtitle = element_text(family="Officina Sans ITC Book", hjust = 0, vjust = -1.5),
        text=element_text(family="Officina Sans ITC Book"))

rbd_plot

# save to daily file
ggsave("hosp_rbd.png", width = 16.6, height = 8.65, units = "in")
