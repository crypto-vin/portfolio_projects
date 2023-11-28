
SELECT *
FROM project1..CovidDeaths
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM project1..CovidDeaths
ORDER BY 1, 2

-- Check total cases vs total deaths(%)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM project1..CovidDeaths
WHERE location LIKE '%kenya%'
ORDER BY 1, 2

-- Check total cases vs population(%)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM project1..CovidDeaths
WHERE location LIKE '%kenya%'
ORDER BY 1, 2

-- Check countries with highest infection rayes as compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS InfectedPercentage
FROM project1..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Check countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM project1..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Check continents with highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM project1..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global statistics
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM project1..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2

-- VACINATION DATA

--Check total population vs vacination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
, (total_vaccinations/dea.population)*100 as percentage_vaccinated
FROM project1..CovidDeaths dea
JOIN project1..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Using a CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, Total_vaccinations, Percentage_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
, (total_vaccinations/dea.population)*100 as percentage_vaccinated
FROM project1..CovidDeaths dea
JOIN project1..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac

-- Using a TEMP Table

DROP TABLE #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccinations numeric,
Percentage_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
, (total_vaccinations/dea.population)*100 as percentage_vaccinated
FROM project1..CovidDeaths dea
JOIN project1..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *
FROM #PercentPopulationVaccinated


-- CREATING VIEWS FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
, (total_vaccinations/dea.population)*100 as percentage_vaccinated
FROM project1..CovidDeaths dea
JOIN project1..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is NOT NULL
