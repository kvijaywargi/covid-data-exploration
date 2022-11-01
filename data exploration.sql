/*
Data Exploration - BigQuery
Dataset - Covid-19 Dataset from https://ourworldindata.org/ 
Limits - Data is downloaded on Oct 19,2022. 
*/
/*
This was a huge dataset. Firstly it was split into two datasets 
using Excel - Covid deaths and Covid Vaccination datasets
*/

  -- *********** EXPLORING COVID_DEATHS TABLE *************
SELECT
  *
FROM
  `gac.portfolio01.covid-deaths`
ORDER BY
  3, 4; -- order by location and date

  -- select the data that is more useful for the analysis
SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM
  `gac.portfolio01.covid-deaths`
ORDER BY
  1,2;
  
  --total cases vs  total deaths
  --shows likelihood of dying if you contract covid in your country
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS deathPercent
FROM
  `gac.portfolio01.covid-deaths`
ORDER BY
  1,2;

  --countires with highest death count per population
SELECT
  location,
  population,
  MAX(total_deaths) AS highestDeathCount,
  MAX((total_deaths/population)*100) AS highestPercentPopulationDeaths
FROM
  `gac.portfolio01.covid-deaths`
GROUP BY
  location,
  population
ORDER BY
  highestPercentPopulationDeaths DESC;

  --total cases vs population
  --shows that percent of population got covid
SELECT
  location,
  date,
  population,
  total_cases,
  (total_cases/population)*100 AS Percent
FROM
  `gac.portfolio01.covid-deaths`
ORDER BY
  1,2;

  --looking at countries with highest infection rate compared to population
SELECT
  location,
  population,
  MAX(total_cases) AS highestInfectionCount,
  MAX((total_cases/population)*100) AS highestPercentPopulationInfected
FROM
  `gac.portfolio01.covid-deaths`
GROUP BY
  location,
  population
ORDER BY
  highestPercentPopulationInfected DESC;

  --looking at countries with the highest death count per population
SELECT
  location,
  MAX(total_deaths) AS totalDeathCount
FROM
  `gac.portfolio01.covid-deaths`
WHERE
  continent IS NOT NULL   --this condition filters the data which has continent names as location and their continent is null, can be applied to above queries as well
GROUP BY
  location
ORDER BY
  totalDeathCount DESC;


  --BREAKING THINGS DOWN BY CONTINENT
  --total deaths in a continent
SELECT
  continent,
  SUM(new_deaths) AS totalDeathCount
FROM
  `gac.portfolio01.covid-deaths`
  --where continent is not null
GROUP BY
  continent
ORDER BY
  totalDeathCount DESC;

  --another way of looking at total deaths
SELECT
  continent,
  SUM(maxDeathsPerLoc)
FROM (
  SELECT
    continent,
    location,
    MAX(total_deaths) AS maxDeathsPerLoc
  FROM
    `gac.portfolio01.covid-deaths`
  WHERE
    continent LIKE '%Asia%'
  GROUP BY
    continent,
    location )
GROUP BY
  continent;

  --GLOBAL NUMBERS
  --total cases and total deaths on each day across the world
SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  (SUM(new_deaths)/SUM(new_cases))*100 AS deathPercent
FROM
  `gac.portfolio01.covid-deaths`
WHERE
  continent IS NOT NULL
GROUP BY
  date
ORDER BY
  1;

  --total cases and total deaths overall
SELECT
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  (SUM(new_deaths)/SUM(new_cases))*100 AS deathPercent
FROM
  `gac.portfolio01.covid-deaths`
WHERE
  continent IS NOT NULL;

  --looking at income wise distribution of the data (doesn't seem credible, might check later)
SELECT
  location,
  SUM(new_cases) AS total_cases
FROM
  `gac.portfolio01.covid-deaths`
WHERE
  location IN ('High income',
    'Low income',
    'Lower middle income',
    'Upper middle income')
GROUP BY
  location;

  --***********EXPLORING COVID-VAX TABLE**************
SELECT
  *
FROM
  `gac.portfolio01.covid-vax`
ORDER BY
  3,4;

  --select the data we will be using
SELECT
  continent,
  location,
  date,
  new_vaccinations,
  total_vaccinations
FROM
  `gac.portfolio01.covid-vax`
WHERE
  continent IS NOT NULL
ORDER BY
  2,3;

  --cummulative total vax based on daily new vax
SELECT
  continent,
  location,
  date,
  new_vaccinations,
  SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS cummulative_vaccinations
FROM
  `gac.portfolio01.covid-vax`
WHERE
  continent IS NOT NULL
ORDER BY
  2,3;

  --finding out the total vax for each location
WITH
  vaxData AS (
  SELECT
    continent,
    location,
    date,
    new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS cummulative_vaccinations
  FROM
    `gac.portfolio01.covid-vax`
  WHERE
    continent IS NOT NULL )
SELECT
  location,
  MAX(cummulative_vaccinations)
FROM
  vaxData
GROUP BY
  location
ORDER BY
  1;

--already existing total vaccination column data 
SELECT
  location,
  MAX(total_vaccinations)
FROM
  `gac.portfolio01.covid-vax`
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  1;


  --********COMBINING TWO TABLES*******
  --Percent population vaccinated
  --by looking at UNited States population vs vaccination numbers, seems like new_vaccinations include data of more than one dose.
WITH
  vaxData AS(
  SELECT
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS cummulative_vaccinations
  FROM
    `gac.portfolio01.covid-deaths` cd
  JOIN
    `gac.portfolio01.covid-vax` cv
  ON
    cd.location = cv.location
    AND cd.date = cv.date
  WHERE
    cd.continent IS NOT NULL
    --and cd.location like '%States'
    )
SELECT
  *,
  (cummulative_vaccinations/population)*100 AS vaxPercent
FROM
  vaxData;


  --percent population having booster
WITH
  vaxData AS(
  SELECT
    cd.continent,
    cd.location,
    cd.population,
    MAX(cv.total_vaccinations) AS total_vax,
    MAX(cv.total_boosters) AS total_boosters
  FROM
    `gac.portfolio01.covid-deaths` cd
  JOIN
    `gac.portfolio01.covid-vax` cv
  ON
    cd.location = cv.location
    AND cd.date = cv.date
  WHERE
    cd.continent IS NOT NULL
  GROUP BY
    1,2,3 )
SELECT
  *,
  (total_vax/population)*100 AS percentVaxxed,
  (total_boosters/population)*100 AS percentBoosted
FROM
  vaxData
ORDER BY
  1,2;
