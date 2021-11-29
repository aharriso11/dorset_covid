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
  pals,
  ggthemes,
  ggtext
)

# IMPORT DATASETS ----

covid_cases_pos <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=utla&metric=uniqueCasePositivityBySpecimenDateRollingSum&format=csv"))

# MUNGE DATA ----

# subset to last three months
covid_cases_pos <- subset(covid_cases_pos, date > today() - months(3))

# define the date format
covid_cases_pos$date = as.Date(covid_cases_pos$date, "%Y-%m-%d")

# Dorset subset
subset_dor <- covid_cases_pos %>% 
  filter(areaName=="Dorset") 

# BCP subset
subset_bcp <- covid_cases_pos %>%
  filter(areaName=="Bournemouth, Christchurch and Poole")

# Create plot and geoms
covid_cases_pos_plot <- ggplot() +
  # background data
  geom_line(data = covid_cases_pos, aes(x = date, y = uniqueCasePositivityBySpecimenDateRollingSum, group = areaName, colour = areaName), size = 0.5, show.legend = FALSE, colour = "grey80") +
  # Dorset line
  geom_line(data = subset_dor, aes(x = date, y = uniqueCasePositivityBySpecimenDateRollingSum, group = areaName, colour = areaName), colour = "green4", size = 1) +
  # BCP line
  geom_line(data = subset_bcp, aes(x = date, y = uniqueCasePositivityBySpecimenDateRollingSum, group = areaName, colour = areaName), colour = "magenta4", size = 1) +
  # x axis config
  scale_x_date(date_labels = "%d %B", date_breaks = "2 weeks") +
  # y axis config
  scale_y_continuous(position = "right") +
  # labels
  xlab("Date") +
  ylab("Unique case positivity by specimen date rolling sum") +
  # set title subtitle and caption
  ggtitle("Covid test positivity - Dorset comparison with England upper tier local authorities") +
  labs(subtitle = "The percentage of people in <span style='color:green4;'>Dorset</span> and <span style='color:magenta4;'>BCP</span> who took a polymerase chain reaction (PCR) test for COVID-19 in rolling 7-day periods who had at least one positive COVID-19 <br>PCR test result in the same 7 days. Data are shown by the date the sample was taken from the person being tested. People who tested more than once in the 7-day period <br>are only counted once in the denominator, and people with more than one positive test result in the period are only counted once in the numerator.", 
       caption = paste("Data from UK Health Security Agency / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " ")) +
  # set theme
  theme_fivethirtyeight() +
  theme(axis.line.x = element_line(size=.5, colour = "black"),
        legend.position="bottom", 
        legend.direction="horizontal", 
        legend.title = element_blank(),
        plot.title=element_text(hjust = 0, vjust = 1.5),
        # subtitle element must be markdown to display html
        plot.subtitle = element_markdown(hjust = 0, vjust = -0.1),
        )

covid_cases_pos_plot

# SAVE OUTPUT ----

# save to daily file
ggsave("output/daily_test_positivity.png", width = 16.6, height = 8.65, units = "in")


