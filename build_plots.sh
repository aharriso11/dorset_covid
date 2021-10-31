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
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid cases age.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid cases utlas.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/R/covid new lfd tests.R"

vardate="Data plots last updated: "$(date +%Y-%m-%d)
sed -i '' -e "1s/.*/$vardate/" README.md

cd /users/andrewharrison/Documents/Github/sandpit

echo "push_${commit_string}"

git add .
git commit -am "push_${commit_string}"
git push
