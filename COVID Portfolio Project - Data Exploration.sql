/* Covid-19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Select data which we will be using further on

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Total cases vs total deaths
-- Shows likelihood of dying if contract Covid in chosen country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Poland'
ORDER BY 1,2


-- Total cases vs population
-- Shows what percantage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like 'Poland'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continents with Highest Death Count per Population 

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid vaccine

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPeopleVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM PercentPeopleVaccinated
