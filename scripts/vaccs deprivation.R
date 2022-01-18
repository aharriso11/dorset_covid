# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/dorset_covid")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  tidyr,
  dplyr,
  zoo,
  reshape,
  lubridate,
  plotly,
  data.table,
  ggthemes,
  ggtext,
  ggrepel
)

# IMPORT DATASETS ----

df_iod <- read.csv(url("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/845345/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators_3.csv"))
df_lookup <- read.csv(url("http://geoportal1-ons.opendata.arcgis.com/datasets/fe6c55f0924b4734adf1cf7104a0173e_0.csv"))
vaccs_percentage_dor <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=msoa&areaCode=E06000059&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))
vaccs_percentage_bcp <- read.csv(url("https://api.coronavirus.data.gov.uk/v2/data?areaType=msoa&areaCode=E06000058&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationSecondDoseUptakeByVaccinationDatePercentage&metric=cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage&format=csv"))

# MUNGE VACCINATION DATA ----

# merge vaccination datasets into one
# 1 - place datasets into a single list
vaccs_percentage_list <- list(vaccs_percentage_dor, vaccs_percentage_bcp)

# 2 - merge the datasets in the list into vaccs_combined
vaccs_percentage_combined <- merge_recurse(vaccs_percentage_list)

# keep only the columns we need, and rename the vacc event columns
vaccs_percentage_combined <- subset(vaccs_percentage_combined, select = c("date", "UtlaName", "areaCode", "areaName", "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage", "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage", "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"))
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage"] <- "First"
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationSecondDoseUptakeByVaccinationDatePercentage"] <- "Second"
names(vaccs_percentage_combined)[names(vaccs_percentage_combined) == "cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage"] <- "Third or booster"

# define the date format
vaccs_percentage_combined$date = as.Date(vaccs_percentage_combined$date, "%Y-%m-%d")

# convert wide data into long
vaccs_percentage_long <- gather(vaccs_percentage_combined, event, total, First:last_col())

# work out unvaccinated percentages
vaccs_percentage_long <- vaccs_percentage_long %>%
  mutate(unvacc_total = 100 - total)

# MUNGE INDEX OF DEPRIVATIOM DATA ----

# create a working dataframe with the Index of Multiple Deprivation columns we need
df_work <- subset(df_iod, select = c("LSOA.code..2011.", "LSOA.name..2011.", "Local.Authority.District.code..2019.", "Local.Authority.District.name..2019.", "Index.of.Multiple.Deprivation..IMD..Score", "Total.population..mid.2015..excluding.prisoners."))

# filter the working dataframe to the Dorset LAs
df_work <- df_work %>%
  filter(Local.Authority.District.code..2019. == "E06000059" | Local.Authority.District.code..2019. == "E06000058")

# get the MSOA code from the LSOA/MSOA lookup table
df_work$msoacode <- with(df_lookup, MSOA11CD[match(df_work$LSOA.code..2011., LSOA11CD)])

# get the legacy LA name (pre LGR) from the LSOA/MSOA lookup table - useful for Dorset
df_work$legacylad <- with(df_lookup, LAD17NM[match(df_work$LSOA.code..2011., LSOA11CD)])

# get the geographic MSOA name from the vaccination data
df_work$msoaname <- with(vaccs_percentage_long, areaName[match(df_work$msoacode, areaCode)])

# following the IMD technical guidance, create a IMD multiplier by multiplying LSOA population by IMD score
df_work <- df_work %>%
  mutate(msoa_dep_multiplier = Total.population..mid.2015..excluding.prisoners. * Index.of.Multiple.Deprivation..IMD..Score)

# AGGREGATE LSOA TO MSOA

# group the LSOAs by MSOA and add their population figures together - creates a new lookup table
df_msoapops <- df_work %>%
  group_by(msoacode) %>%
  summarise(msoapop = sum(Total.population..mid.2015..excluding.prisoners.))

# group the LSOAs by MSOA and add their multiplied scores together - creates a new lookup table
df_msoaimdscore <- df_work %>%
  group_by(msoacode) %>%
  summarise(msoaimdagg = sum(msoa_dep_multiplier))

# create the dataset where our IMD score for each MSOA will be calculated, using a subset of df_work
df_msoascores <- subset(df_work, select = c("msoacode", "msoaname", "Local.Authority.District.code..2019.", "Local.Authority.District.name..2019.", "legacylad"))

# remove the duplicate rows to show only unique MSOAs
df_msoascores <- df_msoascores[!duplicated(df_msoascores$msoacode), ]

# get the MSOA's total pupulation from the df_msoapop lookup table
df_msoascores$msoapop <- with(df_msoapops, msoapop[match(df_msoascores$msoacode, msoacode)])

# get the MSOA's total multiplied score from the df_msoaimdscore lookup table 
df_msoascores$msoaimdagg <- with(df_msoaimdscore, msoaimdagg[match(df_msoascores$msoacode, msoacode)])

# divide the MSOA's multiplied score by its total populatiom
# this produces an Index of Multiple Deprivation score at MSOA level
df_msoascores <- df_msoascores %>%
  mutate(msoa_imd_score = msoaimdagg / msoapop)

# MERGE VACCS AND DEPRIVATION DATA

# add the MSOA IMD score to the long vaccination data
vaccs_percentage_long$msoa_imd_score <- with(df_msoascores, msoa_imd_score[match(vaccs_percentage_long$areaCode, msoacode)])

# add the legacy LA to the long vaccination data
vaccs_percentage_long$legacylad <- with(df_msoascores, legacylad[match(vaccs_percentage_long$areaCode, msoacode)])

# PLOT DATA ----

# build plot
unvaxxed_plot <- ggplot(data = subset(vaccs_percentage_long, event == "First")) +
  # create scatter plot
  geom_point(aes(x = msoa_imd_score, y = unvacc_total, col = legacylad), shape = 15, size = 2) +
  # repelling text labels
  geom_text_repel(aes(x = msoa_imd_score, y = unvacc_total, label = areaName), size = 1.75, segment.color = "red", max.overlaps = Inf) +
  # configure legend and scatter plot colours
  scale_colour_manual(name = "Legacy local authority", values = c("Bournemouth" = "royalblue1", "Christchurch" = "grey", "East Dorset" = "orange", "North Dorset" = "darkgreen", "Poole" = "aquamarine3", "Purbeck" = "navy", "West Dorset" = "darkviolet", "Weymouth and Portland" = "green2")) +
  # axis labels
  xlab("Deprivation score") +
  ylab("Unvaccinated percentage") +
  # title and subtitle
  ggtitle("Comparing covid vaccination status with deprivation") +
  labs(caption = paste("Data from UK Health Security Agency and DLUHC / https://coronavirus.data.gov.uk. Plotted", Sys.time(), sep = " "), 
       subtitle = "Percentage of people aged 12 and over in a MSOA that have not yet received a first covid vaccination, plotted against the MSOA's deprivation score.") +
  # theme and theme settings
  theme_base() +
  theme(
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10))

# create plot
unvaxxed_plot

# save to daily file
ggsave("output/deprivation_dorset.png", width = 16.6, height = 8.65, units = "in")
