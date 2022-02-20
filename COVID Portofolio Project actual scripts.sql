

SELECT *
FROM PortofolioProject..['Covid Deaths$']
WHERE continent is not null
ORDER BY 3,4 

--SELECT *
--FROM PortofolioProject..CovidVaccinations$
--ORDER BY 3,4 

-- Select Data that we are going to be using

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..['Covid Deaths$']
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total	 Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, (cast(total_cases as float))as Total_cases ,total_deaths, (cast (total_deaths as float) / total_cases)*100 as DeathPercentage
FROM PortofolioProject..['Covid Deaths$']
WHERE location like '%states'
and continent is not null
ORDER BY 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date,population, (cast(total_cases as float))as Total_cases , (cast (total_cases as float) / population)*100 as PopulationPercentageInfected
FROM PortofolioProject..['Covid Deaths$']
--WHERE location like '%states'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, max(cast(total_cases as float)) as HighestInfectionCount, max(cast(total_cases as float)/population)*100 as PopulationPercentageInfected
FROM PortofolioProject..['Covid Deaths$']
--WHERE location like '%states'
GROUP BY location, population
ORDER BY PopulationPercentageInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT location, max(cast(total_deaths as float)) as TotalDeathCount
FROM PortofolioProject..['Covid Deaths$']
--WHERE location like '%states'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT 


SELECT continent, max(cast(total_deaths as float)) as TotalDeathCount
FROM PortofolioProject..['Covid Deaths$']
--WHERE location like '%states'
WHERE continent is not null	
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Showing continents with the highest death count per Population

SELECT continent, max(cast(total_deaths as float)) as TotalDeathCount
FROM PortofolioProject..['Covid Deaths$']
--WHERE location like '%states'
WHERE continent is not null	
GROUP BY continent
ORDER BY TotalDeathCount desc 

-- Global numbers

SELECT SUM(cast(new_cases as float)) as TotalCases,SUM(cast(new_deaths as float)) as TotalDeaths, 
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
FROM PortofolioProject..['Covid Deaths$']
--WHERE location like '%states'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM PortofolioProject..['Covid Deaths$'] dea
JOIN PortofolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM PortofolioProject..['Covid Deaths$'] dea
JOIN PortofolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM PortofolioProject..['Covid Deaths$'] dea
JOIN PortofolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to Store Date	for later visualisations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM PortofolioProject..['Covid Deaths$'] dea
JOIN PortofolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated