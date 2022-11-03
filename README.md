# Data Exploration  

 Data Exploration on Covid-19 deaths and vaccinations
 
 **Dataset** : Open source Data available from https://ourworldindata.org/ 
 
 **Timeline** : Dataset consists of Covid-19 information from Jan 2020 to the data it was downloaded on, Oct 19,2022 
 
 ## Data Preparation 
 This was a huge dataset with many unwanted fields that does not line with the scope of this project. 
 
 Therefore, the data is split into two sub-datasets (using Excel) - 
 1. **covid-deaths** : continent, location and date wise information on new cases and deaths 
 2. **covid-vax** : continent, location and date wise information on tests, vaccinations and boosters

The analysis that I wanted to show was based on population vs different metrics. So made sure to make _population_ field available in both datasets. 
 
 ## Data Exploration using SQL in BigQuery
A high level data insights were drawn from the vast data. 
- Total Cases vs Total Deaths : Shows the likelihood of death if you contract covid in your country
- Likelihood of death yearwise : Likelihood decreases in 2022
- Population vs Deaths : Countries with highest death count per population
- Population vs Total Cases : Percent population of a country that contracted covid
- Countries with Highest Infection Rate
- Countries with Highest Death Rate
- Continent wise numbers
- Global Numbers
- Cummulative Total Vaccinations in a country
- Population vs Vaccinations: Percent population vaccinated

## Data Visualization in Tableau
Link to Tableau Dashboard : [here](https://public.tableau.com/views/CovidDashboard1_16669219744150/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link)
