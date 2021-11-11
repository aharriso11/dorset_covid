cd /users/andrewharrison/Documents/GitHub/dorset_covid/hospital_preparation

file_url=$(curl -v --silent https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/ 2>&1 | 
  grep Weekly-covid-admissions | 
  grep -v up-to |
  grep -o 'https://[^"]*')


file_name=$file_url | cut -d'/' -f10

file_name=https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2021/11/Weekly-covid-admissions-and-beds-publication-211104.xlsx | cut -d'/' -f10

https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2021/11/Weekly-covid-admissions-and-beds-publication-211104.xlsx

wget $file_url

ssconvert -S $file_name weekly.csv

mv weekly.csv.0 hospads.csv
mv weekly.csv.5 allbedscovid.csv
mv weekly.csv.6 allbedsmv.csv

rm weekly*
rm Weekly*

death_file_url="https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2021/11/COVID-19-total-announced-deaths-08-November-2021.xlsx"
death_file_name="COVID-19-total-announced-deaths-08-November-2021.xlsx"

wget $death_file_url

ssconvert -S $death_file_name deaths.csv

mv deaths.csv.8 trustdeaths.csv

rm deaths*