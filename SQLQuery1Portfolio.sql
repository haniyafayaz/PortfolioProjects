SELECT *FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
--SELECT *FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA
SELECT LOCATION,DATE,TOTAL_CASES,NEW_CASES,TOTAL_DEATHS,POPULATION
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%INDIA%'
AND continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
SELECT LOCATION,DATE,POPULATION,TOTAL_CASES, (TOTAL_CASES/POPULATION)*100 AS INFECTEDPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%INDIA%'
AND continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE
SELECT LOCATION,POPULATION,MAX(TOTAL_CASES) AS HIGHESTINFECTIONCOUNT, MAX((TOTAL_CASES/POPULATION))*100 AS INFECTEDPERCENTAGE
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%INDIA%'
GROUP BY LOCATION,POPULATION
ORDER BY INFECTEDPERCENTAGE DESC

--SHOWING COUNTRIES W HIGHEST DEATH COUNT PER POPULATION
SELECT LOCATION,MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TOTALDEATHCOUNT DESC

--BREAKING THE THINSG UO BY CONTINENT
SELECT LOCATION,MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%INDIA%'
WHERE continent IS NULL
GROUP BY LOCATION
ORDER BY TOTALDEATHCOUNT DESC

--SHOWING CONTINENTS W HIGHEST DEATH COUNT PER POPULATION
SELECT continent,MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY CONTINENT
ORDER BY TOTALDEATHCOUNT DESC

--GLOBAL NUMBERS
SELECT SUM(NEW_CASES) AS TOTAL_CASES,SUM(CAST(NEW_DEATHS AS INT)) AS TOTAL_DEATHS, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%INDIA%'
WHERE continent IS NOT NULL
--GROUP BY DATE
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
ORDER BY 2,3

--WITH CTE
WITH POPVSVAC (CONTINENT, LOCATION,DATE,POPULATION,NEW_VACCINATIONS,ROLLINGPEOPLEVACCINATED)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM POPVSVAC

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
--where dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
from  #PercentPopulationVaccinated

-- CREATING A VIEW TO STORE DATA FOR VISUALIZATION
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--ORDER BY 2,3

SELECT *FROM PercentPopulationVaccinated
