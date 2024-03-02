-- Death percentage for the United States from begining to last record (22-02-2024).

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states'
ORDER BY 1,2

-- Same as before, now for Chile (18-02-2024).

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Chile'
ORDER BY 1,2

-- Infection percentage as of the date of last record in USA.

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectPercentage
FROM CovidDeaths
WHERE location like '%states'
ORDER BY 1,2

--	Countries with the highest infection percentages as of last record (in any case).

SELECT location, population, MAX(total_cases) as HighestInfectCount, MAX((total_cases/population)*100) AS InfectPercentage
FROM CovidDeaths
WHERE continent	IS NOT NULL
GROUP BY location, population
ORDER BY InfectPercentage DESC

-- Countries with the highest death counts as of last record.

SELECT location, population, MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths
WHERE continent	IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC

-- Countries with the highest death percentages as of last record.

SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)*100) AS DeathPercentage
FROM CovidDeaths
WHERE continent	IS NOT NULL
GROUP BY location, population
ORDER BY DeathPercentage DESC

-- Death counts and death percentages by continen as of last record.

SELECT continent, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)*100) AS DeathPercentage
FROM CovidDeaths
WHERE continent	IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage DESC

-- Daily death percentage for global data, omiting dates without records and total death percentage as of last record.

SELECT date, SUM(new_cases) AS TotalDailyCases, SUM(new_deaths) AS TotalDailyDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DailyDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0
GROUP BY date
ORDER BY 1

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0
ORDER BY 1

-- Lethality as of July 2020, end of 2020, end of 2021 and end of 2022.

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0 AND date < '2020-06-01'
ORDER BY 1

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0 AND date < '2020-12-31'
ORDER BY 1

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0 AND date < '2021-12-31'
ORDER BY 1

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0 AND date < '2022-12-31'
ORDER BY 1

-- New and cumulative vaccinations by country and date, when records are available.

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT))
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS CumulativeVaccinations
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3

-- Using CTE for new calculations over query.

WITH cte_death_vac (continent, location, date, population, new_vaccinations, CumulativeVaccinations)
AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT))
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS CumulativeVaccinations
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)
SELECT *, (CumulativeVaccinations/population)*100 AS VaccinationPercentage, MAX((CumulativeVaccinations/population)*100)
OVER (PARTITION BY cte_death_vac.continent ORDER BY cte_death_vac.location) AS MaxVaccinationPercentage
FROM cte_death_vac
ORDER BY 2,3

-- Using TEMP table

DROP TABLE IF EXISTS #temp_death_vac
CREATE TABLE #temp_death_vac (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativevaccinations numeric
)

INSERT INTO #temp_death_vac
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT))
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS CumulativeVaccinations
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *, (cumulativevaccinations/population)*100 AS VaccinationPercentage, MAX((cumulativevaccinations/population)*100)
OVER (PARTITION BY #temp_death_vac.continent ORDER BY #temp_death_vac.location) AS MaxVaccinationPercentage
FROM #temp_death_vac
ORDER BY 2,3

-- Creating view of useful data for further use

CREATE VIEW VaccinationNewCumulativeClean AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT))
OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS CumulativeVaccinations
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

-- Query on created view

SELECT *
FROM VaccinationNewCumulativeClean