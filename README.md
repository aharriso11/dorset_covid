Data plots last updated: 2021-10-30

# Andrew's Dorset and BCP covid statistics

This is the output of me playing around with the R statistical programming language and the coronavirus data produced on a daily basis by Public Health England and published at [https://coronavirus.data.gov.uk](https://coronavirus.data.gov.uk), focusing on the local authority areas of [Dorset](https://www.dorsetcouncil.gov.uk/) and [Bournemouth, Christchurch and Poole](https://www.bcpcouncil.gov.uk/).

I'm publishing these interpretations of data already in the public domain purely for my personal interest. They're updated when I feel like it, and you should always check the dates on the data plots to see how old they are. To see the most up-to date information you should always check Public Health England's dashboard at [https://coronavirus.data.gov.uk](https://coronavirus.data.gov.uk). I am not a statistician or an epidemiologist, or any kind of expert in this field. **This information is offered on a best endeavours basis for your own interest and you should not use it for any other purpose.**

For authoritative information regarding the prevalence of covid-19 in Dorset or BCP you should visit the website of [Public Health Dorset](https://www.publichealthdorset.org.uk/).

If you find these statistics of interest you may also enjoy my blog posts on [generating the R code behind the England case rates plot](https://www.ajharrison.org.uk/2021/05/03/interpreting-covid-case-rates-with-r/), and the [importance of working with 'long data' as opposed to 'wide data'](https://www.ajharrison.org.uk/2021/05/22/converting-wide-data-into-long-with-r/). You can also look at the underlying R source code at [https://github.com/aharriso11/dorset_covid](https://github.com/aharriso11/dorset_covid)

## Dorset daily vaccinations
Booster or third vaccination data is not yet published to local authority level, to see national level data that shows these [visit the relevant page of the PHE covid dashboard](https://coronavirus.data.gov.uk/details/vaccinations?areaType=nation&areaName=England).
[![Dorset daily vaccinations](daily_dorset_vaccinations.png)](daily_dorset_vaccinations.png?raw=true)

## Dorset daily vaccinations as percentage of population
Booster or third vaccination data is not yet published to local authority level, to see national level data that shows these [visit the relevant page of the PHE covid dashboard](https://coronavirus.data.gov.uk/details/vaccinations?areaType=nation&areaName=England).
[![Dorset daily vaccinations as percentage of population](daily_dorset_vaccs_percentage.png)](daily_dorset_vaccs_percentage.png?raw=true)

## England daily cases
[![England daily cases](daily_england_cases.png)](daily_england_cases.png?raw=true)

## Dorset daily cases
[![Dorset daily cases](daily_dorset_cases.png)](daily_dorset_cases.png?raw=true)

## Dorset MSOA rolling rates
The MSOA rolling rates are presented as a separate web page.
[![Dorset MSOA rolling rates](dorset_msoa_cases.png)](msoa_cases.html)

## Dorset new cases by age
The new cases breakdown by age groups are shown on a separate web page.
[![Dorset new cases by age](dorset_age_cases.png)](age_cases.html)

## Dorset daily hospital admissions
The [NHS England website](https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/) provides much greater detail on hospital admissions than either this website or the PHE dashboard.
[![Dorset daily admissions](daily_dorset_admissions.png)](daily_dorset_admissions.png?raw=true)
