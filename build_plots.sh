#!/bin/bash
set -x #echo on

rm -f timestamp*

commit_string=$(date +%Y_%m_%d_%H%M)

touch "timestamp${commit_string}"

/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid admissions dorset.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid dorset cases.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid daily cases.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid dorset vaccinations.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid dorset vaccs percentage.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid msoa.R"

cd /users/andrewharrison/Documents/Github/sandpit

echo "push_${commit_string}"

git add .
git commit -am "push_${commit_string}"
git push
