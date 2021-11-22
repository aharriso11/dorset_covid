Data plots last updated: 2021-11-22

# Andrew's Dorset and BCP covid statistics

This is the output of me playing around with the [R statistical programming language](https://rafalab.github.io/dsbook/getting-started.html) and the coronavirus data produced on a daily basis by the UK Health Security Agency (UKHSA) and published at [https://coronavirus.data.gov.uk](https://coronavirus.data.gov.uk), focusing on the local authority areas of [Dorset](https://www.dorsetcouncil.gov.uk/) and [Bournemouth, Christchurch and Poole](https://www.bcpcouncil.gov.uk/).

I'm publishing these interpretations of data already in the public domain purely for my personal interest. They're updated when I feel like it, and you should always check the dates on the data plots to see how old they are. To see the most up-to date information you should always check UKHSA's dashboard at [https://coronavirus.data.gov.uk](https://coronavirus.data.gov.uk). I am not a statistician or an epidemiologist, or any kind of expert in this field. **This information is offered on a best endeavours basis for your own interest and you should not use it for any other purpose.**

For authoritative information regarding the prevalence of covid-19 in Dorset or BCP you should visit the website of [Public Health Dorset](https://www.publichealthdorset.org.uk/).

If you find these statistics of interest you may also enjoy my blog posts on [generating the R code behind the England case rates plot](https://www.ajharrison.org.uk/2021/05/03/interpreting-covid-case-rates-with-r/), and the [importance of working with 'long data' as opposed to 'wide data'](https://www.ajharrison.org.uk/2021/05/22/converting-wide-data-into-long-with-r/). You can also look at the underlying R source code at [https://github.com/aharriso11/dorset_covid](https://github.com/aharriso11/dorset_covid).

To see what's changed on these pages visit the [change log](CHANGELOG.md)

You can see a larger version of each data plot by clicking on it.

## International comparison
An international comparison of cases and vaccinations per million between the UK and the European countries experiencing high case rates in autumn 2021 [is available on a separate page](international.md).

## Dorset daily vaccinations
Booster or third vaccination data are not yet published to local authority level, to see national level data plots that show these [visit the relevant page of the PHE covid dashboard](https://coronavirus.data.gov.uk/details/vaccinations?areaType=nation&areaName=England).
[![Dorset daily vaccinations](daily_dorset_vaccinations.png)](daily_dorset_vaccinations.png?raw=true)

## Dorset daily vaccinations as percentage of population
Booster or third vaccination data are not yet published to local authority level, to see national level data plots that show these [visit the relevant page of the UKHSA covid dashboard](https://coronavirus.data.gov.uk/details/vaccinations?areaType=nation&areaName=England).
[![Dorset daily vaccinations as percentage of population](daily_dorset_vaccs_percentage.png)](daily_dorset_vaccs_percentage.png?raw=true)

## England daily cases
[![England daily cases](daily_england_cases.png)](daily_england_cases.png?raw=true)

## Dorset daily cases
[![Dorset daily cases](daily_dorset_cases.png)](daily_dorset_cases.png?raw=true)

## Dorset daily case comparison with other upper tier local authorities
This chart also shows the top five upper tier local authorities
[![Dorset daily case comparison](daily_cases_utlas.png)](daily_cases_utlas.png?raw=true)

## Dorset daily case comparison with south west lower tier local authorities
This chart also highlights LTLAs most affected by the recent [Immensa PCR testing failure](https://www.standard.co.uk/news/uk/exeter-government-taunton-somerset-nhs-england-b961477.html) in red and is presented on this page as a dynamic data plot. You can also view the dynamic data plot [at full size on a separate page](sw_cases.html), or view a [static version](sw_cases.png?raw=true).
<iframe src="sw_cases.html" title="South west case focus" width=1000 height=700></iframe>

## Dorset MSOA rolling rates
A dynamic data plot showing the MSOA rolling rates which can also be seen [at full size on a separate web page](msoa_cases.html).
<iframe src="msoa_cases.html" title="MSOA case focus" width=1000 height=700></iframe>

## Dorset new cases by age
A dynamic data plot showing the new cases broken down by age which can also be seen [at full size on a separate web page](age_cases.html).
<iframe src="age_cases.html" title="Age case focus" width=1000 height=700></iframe>

### New cases by age distribution
[![New cases by age distribution](dorset_age_cases_percentage.png)](dorset_age_cases_percentage.png?raw=true)

## Dorset daily lateral flow device tests recorded
This chart shows the number of lateral flow device tests (both negative and positive) being recorded each day, broken down by local authority. A negative and positive breakdown is not available at local authority level, for more information on testing [visit the relevant page of the UKHSA dashboard](https://coronavirus.data.gov.uk/details/testing)
[![Dorset daily LFD tests](daily_lfd.png)](daily_lfd.png)

## Dorset daily hospital admissions
See [NHS trust level data for hospital admissions, bed occupancy and deaths](hospital_activity.MD).

The [NHS England website](https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/) provides much greater detail on hospital admissions than either this website or the UKHSA dashboard. 
[![Dorset daily admissions](daily_dorset_admissions.png)](daily_dorset_admissions.png?raw=true)
