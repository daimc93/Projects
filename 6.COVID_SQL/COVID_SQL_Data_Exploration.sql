--SELECT *
--FROM Portfolio_Project..CovidDeaths
--WHERE continent is not NULL
--ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage 
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage 
FROM Portfolio_Project..CovidDeaths
WHERE location LIKE '%chile%'
AND continent is not NULL
ORDER BY 1,2

-- Total cases vs population
-- Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases,  (total_cases/population)*100 PercentPopulationInfected 
FROM Portfolio_Project..CovidDeaths
WHERE location LIKE '%chile%'
AND continent is not NULL
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT location,  population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 PercentPopulationInfected 
FROM Portfolio_Project..CovidDeaths
--WHERE location LIKE '%chile%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
--WHERE location LIKE '%chile%'
GROUP BY location
ORDER BY TotalDeathCount  DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Contintents with the highest death count 
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
--WHERE location LIKE '%chile%'
GROUP BY continent
ORDER BY TotalDeathCount  DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%chile%'
where continent is not null 
Group By date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%chile%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE 
WITH PoopvsVac (Continent, Location, Date, Population, New_Vacinations, RollingPeopleVaccinated)
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 
	FROM Portfolio_Project..CovidDeaths dea
	JOIN Portfolio_Project..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PoopvsVac
ORDER BY 2,3

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vacinations numeric, 
	RollingPeopleVaccinated numeric 
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 
	FROM Portfolio_Project..CovidDeaths dea
	JOIN Portfolio_Project..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- Creating view to store data for visualilzation
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
