#!/bin/bash
set -x #echo on

cd ~/Documents/GitHub/dorset_covid

rm -f timestamp*

commit_string=$(date +%Y_%m_%d_%H%M)

touch "timestamp${commit_string}"

/usr/bin/r "covid admissions dorset.R"
/usr/bin/r "covid dorset cases.R"
/usr/bin/r "covid daily cases.R"
/usr/bin/r "covid dorset vaccinations.R"
/usr/bin/r "covid dorset vaccs percentage.R"
/usr/bin/r "covid msoa.R"



echo "push_${commit_string}"

git add .
git commit -am "push_${commit_string}"
git push
