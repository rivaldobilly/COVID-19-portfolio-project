SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

SELECT * 
FROM PortfolioProject..CovidVaccinations 
WHERE continent is not null
ORDER BY 3,4;

DROP TABLE PortfolioProject..CovidVaccinations;


--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID-19 in your country

--convert (int, A.total_cases)
--cast(total_cases as int)

SELECT location, date, convert(int, total_cases) AS total_cases, convert(int, total_deaths) AS total_deaths, (convert(int, total_deaths)/convert(int, total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Indonesia'
AND continent is not null
ORDER BY 1,2;


--Looking at Total Cases vs Populations
--Shows what percentage of population got COVID-19

SELECT location, date, population, convert(int, total_cases) AS total_cases, (convert(int, total_cases)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Cyprus'
AND continent is not null
ORDER BY 1,2;


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(cast(total_cases as int)) AS HighestInfectionCount, MAX(cast(total_cases as int)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Showing continents with the highest death per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
and dea.location = 'Indonesia'
ORDER BY 2,3;


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated;

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationsVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;

SELECT * 
FROM PercentPopulationsVaccinated;