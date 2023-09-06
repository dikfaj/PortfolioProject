SELECT TOP 1000 * 
FROM CovidDeaths
--WHERE continent is not null
ORDER BY 3,4



--SELECT TOP 10 * FROM CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at total case vs total deaths
--Show likelihood of dying if you contact with covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Indonesia'
ORDER BY 1,2

--Looking at total case vs population
--show what populations got covid

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
WHERE location = 'Indonesia'
ORDER BY 1,2

--Looking at country with highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPoplutionInfected
FROM CovidDeaths
Group by location, population
order by PercentPoplutionInfected DESC

--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population VS vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USING CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 as Percentage
FROM PopvsVac

--USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as Percentage
FROM #PercentPopulationVaccinated


--For visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated