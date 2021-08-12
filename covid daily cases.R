# LOAD LIBRARIES ----

library("ggplot2")
library("dplyr")
library("zoo")

# IMPORT DATASET ----

covid_cases_csv <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newCasesBySpecimenDate&format=csv"))
covid_cases_csv <- covid_cases_csv %>%
  dplyr::mutate(cases_07da = zoo::rollmean(newCasesBySpecimenDate, k = 7, fill = NA))

# FORMAT DATA ----

covid_cases_csv$date = as.Date(covid_cases_csv$date, "%Y-%m-%d")
less_recent_days <- Sys.Date() - 5
less_seven_days <- less_recent_days - 7

# PLOT DATA ----

covid_cases_plot <- ggplot(covid_cases_csv[which(covid_cases_csv$date>"2020-10-31" & covid_cases_csv$date<less_recent_days),], aes(x = date, y = cases_07da)) + 
  geom_point(shape = 1, colour = "red", size=2) +
  geom_smooth(data=subset(covid_cases_csv, covid_cases_csv$date >= less_seven_days), method = "lm", colour = "black", size=0.5, fullrange=FALSE, se=FALSE) +
  labs(caption = paste("Data from Public Health England / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "))

covid_cases_plot + 
  scale_y_continuous(trans = 'log10', breaks = c(1000,2000,5000,10000,20000,50000)) +
  scale_x_date(date_labels = "%B %Y", date_breaks = "1 month") +
  ggtitle("England covid cases - 7 day average by specimen date") +
  xlab("Date") +
  ylab("Cases") +
  theme_bw()

# save to daily file
ggsave("~/Documents/R/daily_england_cases.png", width = 16.6, height = 8.65, units = "in")
ggsave("~/Documents/Github/dorset_covid/daily_england_cases.png", width = 16.6, height = 8.65, units = "in")