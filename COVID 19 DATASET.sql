-- CREATE COVID DEATH TABLE

CREATE TABLE CovidDeaths
(
	iso_code varchar,
	continent varchar,
	location varchar,
	date date,
	population int,
	total_cases int,
	new_cases int,
	new_cases_smoothed numeric,
	total_deaths int,
	new_deaths int,
	new_deaths_smoothed numeric,
	total_cases_per_million numeric,
	new_cases_per_million numeric,
	new_cases_smoothed_per_million numeric,
	total_deaths_per_million numeric,
	new_deaths_per_million numeric,
	reproduction_rate numeric,
	icu_patients int,
	icu_patients_per_million numeric,
	hosp_patients numeric,
	hosp_patients_per_million numeric,
	weekly_icu_admissions numeric,
	weekly_icu_admissions_per_million numeric,
	weekly_hosp_admissions numeric,
	weekly_hosp_admissions_per_million numeric
)

-- CREATE COVID VACCINATIONS TABLE

CREATE TABLE covidvaccinations
(
	iso_code varchar,
	continent varchar,
	location varchar,
	date date,
	new_tests numeric,
	total_tests numeric,
	total_tests_per_thousand numeric,
	new_tests_per_thousand numeric,
	new_tests_smoothed numeric,
	new_tests_smoothed_per_thousand numeric,
	positive_rate numeric,
	tests_per_case numeric,
	tests_units varchar,
	total_vaccinations numeric,
	people_vaccinated numeric,
	people_fully_vaccinated numeric,
	new_vaccinations numeric,
	new_vaccinations_smoothed numeric,
	total_vaccinations_per_hundred numeric,
	people_vaccinated_per_hundred numeric,
	people_fully_vaccinated_per_hundred numeric,
	new_vaccinations_smoothed_per_million numeric,
	stringency_index numeric,
	population_density numeric,
	median_age numeric,
	aged_65_older numeric,
	aged_70_older numeric,
	gdp_per_capita numeric,
	extreme_poverty numeric,
	cardiovasc_death_rate numeric,
 	diabetes_prevalence numeric,
	female_smokers numeric,
	male_smokers numeric,
	handwashing_facilities numeric,
	hospital_beds_per_thousand numeric,
	life_expectancy numeric,
	human_development_index numeric
)

SELECT *
FROM coviddeaths

SELECT *
FROM covidvaccinations

-- SELECTING DATA TO USE

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location, date

-- TOTAL CASES VS TOTAL DEATHS

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE location like 'Phil%'
ORDER BY location, date

-- TOTAL CASES VS POPULATION

SELECT location, date, population, total_cases,(total_cases/population) * 100 AS case_percentage
FROM coviddeaths
WHERE location like 'Phil%'
ORDER BY location, date

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS highest_infection_count , MAX((total_cases/population)) * 100 AS case_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY case_percentage DESC

-- COUNTRIES WITH THE HIGHEST DEATH COUNT

SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- CONTINENT/LOCATION BREAKDOWN

SELECT continent, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, SUM(new_cases)

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY SUM(new_cases)

-- JOIN COVID DEATH AND VACCINATIONS 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac."location"
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

WITH pop_vs_vac
(continent,location,date, population, new_vaccinations, rolling_vaccination_count)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
	FROM coviddeaths AS dea
	JOIN covidvaccinations AS vac
		ON dea.location = vac."location"
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_vaccination_count/population)*100 AS vaccination_percentage
FROM pop_vs_vac

-- TEMP TABLE WAY

DROP TABLE IF EXISTS percent_population_vaccination

CREATE TEMPORARY TABLE percent_population_vaccination
(
	continent varchar,
	location varchar,
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_vaccination_count numeric
)

INSERT INTO percent_population_vaccination
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
	FROM coviddeaths AS dea
	JOIN covidvaccinations AS vac
		ON dea.location = vac."location"
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	
	
SELECT *, (rolling_vaccination_count/population)*100 AS vaccination_percentage
FROM percent_population_vaccination


-----------------------------------------------------------------------------------------------------------------------------------


--TABLEAU VISUALIZATION DATA

--TOTAL CASES, DEATHS , AND DEATH PERCENTAGE

SELECT SUM(new_cases) AS total_cases , SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 AS death_percentage 
FROM coviddeaths
WHERE continent IS NOT NULL

--TOTAL DEATH COUNT BY CONTINENT

SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NULL AND location NOT IN ('European Union','World','International')
GROUP BY location
ORDER BY total_death_count DESC

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS highest_infection_count , MAX((total_cases/population)) * 100 AS case_percentage
FROM coviddeaths
GROUP BY location, population
ORDER BY case_percentage DESC

--WITH DATA

SELECT location, population, date, MAX(total_cases) AS highest_infection_count , MAX((total_cases/population)) * 100 AS case_percentage
FROM coviddeaths
GROUP BY location, population, date
ORDER BY case_percentage DESC