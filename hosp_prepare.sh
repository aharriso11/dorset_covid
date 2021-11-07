cd /users/andrewharrison/Documents/GitHub/dorset_covid/hospital_preparation

file_url="https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2021/11/Weekly-covid-admissions-and-beds-publication-211104.xlsx"
file_name="Weekly-covid-admissions-and-beds-publication-211104.xlsx"

wget $file_url

ssconvert -S $file_name weekly.csv

mv weekly.csv.0 hospads.csv
mv weekly.csv.5 allbedscovid.csv
mv weekly.csv.6 allbedsmv.csv

rm weekly*
rm Weekly*