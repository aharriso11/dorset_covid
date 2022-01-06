#!/bin/bash
set -x #echo on

rm -f timestamp*

commit_string=$(date +%Y_%m_%d_%H%M)

touch "timestamp${commit_string}"

/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid admissions dorset.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid dorset cases.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid daily cases.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid dorset vaccinations.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid dorset vaccs percentage.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid msoa.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid cases age.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid new lfd tests.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid cases utlas.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid cases sw.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/intl cases.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/intl vaccs.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid test positivity.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid cases regions.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid msoa vaccs percentage.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/covid dorset vacc demogs.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/dorset cases change.R"
/usr/local/bin/rscript "/users/andrewharrison/Documents/GitHub/dorset_covid/scripts/hospital focus 2.R"

vardate="Data plots last updated: "$(date +%Y-%m-%d)
sed -i '' -e "1s/.*/$vardate/" README.md

vardate="Data plots last updated: "$(date +%Y-%m-%d)
sed -i '' -e "1s/.*/$vardate/" ./pages/README.md

cd /users/andrewharrison/Documents/Github/dorset_covid

echo "push_${commit_string}"

git add .
git commit -am "push_${commit_string}"
git push
