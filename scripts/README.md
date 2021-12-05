# Andrew's Dorset and BCP covid statistics - scripts

On this page I will try to provide a brief narrative as to what each script does, its data source and (where possible) the metrics it uses.

## Vaccinations

### Dorset daily vaccinations
- Source: UKHSA dashboard
- Metrics
	- [newPeopleVaccinatedFirstDoseByVaccinationDate](https://coronavirus.data.gov.uk/metrics/doc/newPeopleVaccinatedFirstDoseByVaccinationDate)
	- [newPeopleVaccinatedSecondDoseByVaccinationDate](https://coronavirus.data.gov.uk/metrics/doc/newPeopleVaccinatedSecondDoseByVaccinationDate)
	- [newPeopleVaccinatedThirdInjectionByVaccinationDate](https://coronavirus.data.gov.uk/metrics/doc/newPeopleVaccinatedThirdInjectionByVaccinationDate)
- Area type used: ltla
- Area codes used: E06000059 (Bournemouth, Christchurch and Poole), E06000058 (Dorset)
 
### Dorset vaccinations - population percentage over time
- Source: UKHSA dashboard
- Metrics
 - [cumVaccinationFirstDoseUptakeByVaccinationDatePercentage](https://coronavirus.data.gov.uk/metrics/doc/cumVaccinationFirstDoseUptakeByVaccinationDatePercentage)
 - [cumVaccinationSecondDoseUptakeByVaccinationDatePercentage](https://coronavirus.data.gov.uk/metrics/doc/cumVaccinationSecondDoseUptakeByVaccinationDatePercentage)
 - [cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage](https://coronavirus.data.gov.uk/metrics/doc/cumVaccinationThirdInjectionUptakeByVaccinationDatePercentage)
- Area type used: ltla
- Area codes used: E06000059 (Bournemouth, Christchurch and Poole), E06000058 (Dorset)
 
## Cases
 
### England daily cases
- Source: UKHSA dashboard
- Metric
 - [newCasesBySpecimenDate](https://coronavirus.data.gov.uk/metrics/doc/newCasesBySpecimenDate)
- Area type used: nation
- Area codes used: E92000001 (England)

### Dorset daily cases
- Source: UKHSA dashboard
- Metric
 - [newCasesBySpecimenDate](https://coronavirus.data.gov.uk/metrics/doc/newCasesBySpecimenDate)
- Area type used: ltla
- Area codes used: E06000059 (Bournemouth, Christchurch and Poole), E06000058 (Dorset)

## Dorset daily case comparison with other upper tier local authorities
- Source: UKHSA dashboard
- Metric
 - [newCasesBySpecimenDate](https://coronavirus.data.gov.uk/metrics/doc/newCasesBySpecimenDate)
- Area type used: utla
- Area codes used: not specified (returns all)
- Subsets created for plotting:
 - Background data (all upper tier local authorities)
 - Top five upper tier local authorities
 - Bournemouth, Christchurch and Poole
 - Dorset
 
## Dorset test positivity comparison with other upper tier local authorities
- Source: UKHSA dashboard
- Metric: [uniqueCasePositivityBySpecimenDateRollingSum](https://coronavirus.data.gov.uk/metrics/doc/uniqueCasePositivityBySpecimenDateRollingSum)
- Area type used: utla
- Area codes used: not specified (returns all)
- Subsets created for plotting:
 - Background data (all upper tier local authorities)
 - Bournemouth, Christchurch and Poole
 - Dorset
 
## Dorset daily case comparison with south west lower tier local authorities
- Source: UKHSA dashboard
- Metric
 - [newCasesBySpecimenDate](https://coronavirus.data.gov.uk/metrics/doc/newCasesBySpecimenDate)
- Area type used: ltla
- Area codes used: not specified (returns all)
- Subsets created for plotting:
 - Background data (all south west lower tier local authorities, identified using the [Office for National Statistics local authority district to region lookup table](https://geoportal.statistics.gov.uk/datasets/ons::local-authority-district-to-region-april-2021-lookup-in-england/about))
 - South west lower tier local authorities affected by the Immensa testing failure
 - Bournemouth, Christchurch and Poole
 - Dorset
 
## Dorset MSOA rolling rates
- Source: UKHSA dashboard
- Metric
 - [newCasesBySpecimenDateRollingRate](https://coronavirus.data.gov.uk/metrics/doc/newCasesBySpecimenDateRollingRate)