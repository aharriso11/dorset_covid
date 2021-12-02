# change to working directory
cd /users/andrewharrison/Documents/GitHub/dorset_covid/hospital_preparation

# HOSPITAL ACTIVITY FILE PROCESSING ----

# get weekly hospital activity file URL from NHSE hospital activity page
hosp_file_url=$(curl -v --silent https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/ 2>&1 | 
  grep Weekly-covid-admissions | 
  grep -v up-to |
  grep -o 'https://[^"]*')

# extract string from URL
hosp_file_name=$(echo $hosp_file_url | cut -d'/' -f11)

# download hospital activity file
wget $hosp_file_url

# convert hospital activity xlsx to separate csv files
ssconvert -S $hosp_file_name weekly.csv

# rename the files we want to keep
mv weekly.csv.0 hospads.csv
mv weekly.csv.5 allbedscovid.csv
mv weekly.csv.6 allbedsmv.csv

# delete the rest
rm weekly*
rm Weekly*

# DEATH FILE PROCESSING ----

# get daily death file URL from NHSE deaths page
death_file_url=$(curl -v --silent https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-daily-deaths/ 2>&1 | 
  grep COVID-19-total-announced-deaths | 
  grep -v weekly |
  grep -o 'https://[^"]*')

# extract string from URL
death_file_name=$(echo $death_file_url | cut -d'/' -f11)

# download death file
wget $death_file_url

# convert death file xlsx to separate csv files
ssconvert -S $death_file_name deaths.csv

# rename the file we want to keep
mv deaths.csv.8 trustdeaths.csv

# delete the rest
rm deaths*
rm COVID*