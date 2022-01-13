# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

plot_subtitle <- "Some text"
plot_caption <- "Caption"

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  tidyr,
  reshape,
  ggtext,
  data.table,
  ggthemes,
  pals,
  lubridate
)

df <- read_tsv(url("https://covid-surveillance-data.cog.sanger.ac.uk/download/lineages_by_ltla_and_week.tsv"))

df_c <- df %>%
  filter(LTLA == "E06000058" | LTLA == "E06000059") %>%
  filter(WeekEndDate > today() - weeks(52)) %>%
  spread(key = Lineage, value = Count, fill = 0) %>%
  gather(key = Lineage, value = Count, -c(WeekEndDate, LTLA)) %>%
  arrange(WeekEndDate, LTLA, Lineage) %>%
  group_by(WeekEndDate, LTLA) %>%
  mutate(perc = prop.table(Count) * 100)

# PLOT DATA ----

df_plot <- ggplot() +
  geom_area(data = df_d, aes(x = WeekEndDate, y = perc, fill = variant), show.legend = FALSE, position = "stack")

df_plot

# create plot and geom
covid_variant_plot <- ggplot() +
  # plot data in a stacked format
  geom_area(data = df_c, aes(x = WeekEndDate, y = perc, group = Lineage, fill = Lineage), position = "stack", show.legend = FALSE) +
  facet_grid( ~ LTLA) +
  # scale settings
#  scale_fill_manual(name = "Variant"), values = as.vector(tableau20(19))) +
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

dynamic_plot <- ggplotly(covid_variant_plot)

dynamic_plot
