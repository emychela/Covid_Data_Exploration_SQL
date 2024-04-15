SELECT *
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
ORDER BY 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4;

-- Select data that we are going into be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo. CovidDeaths
ORDER BY 1, 2;

--Analyzing Total cases vs Total deaths
--Shows likelihood of dying after covid infection in Kenya.

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo. CovidDeaths
WHERE location LIKE '%Kenya%'
ORDER BY 1, 2;

--Analyzing Total Cases vs Population 
--Shows what percentage of population got covid

SELECT location, date, Population, total_cases,(total_cases/population)*100 AS TotalInfectionPercentage
FROM PortfolioProject.dbo. CovidDeaths
WHERE location LIKE '%Kenya%'
ORDER BY 1, 2;


--Looking at countries with Highest Infection Rate compared to population

SELECT location, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo. CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;


--Showing countries with Highest Death Count per Population 

SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY HighestDeathCount DESC;




SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY HighestDeathCount DESC;


--BREAK THINGS DOWN BY CONTINENT

-- TotalDeathCount- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS null AND location not in ('world', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;



--Showing Continents with Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY HighestDeathCount DESC;

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1, 2;

-- Overall infection and death numbers in the world

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null;


--Join the CovidDeaths and CoividVaccinations Tables

SELECT*
FROM PortfolioProject.dbo. CovidDeaths deaths
JOIN PortfolioProject.dbo. CovidVaccinations Vac
    ON deaths.location = vac.location
	AND deaths.date = vac.date


--Looking at Total Population vs Vaccinations

SELECT deaths.continent, deaths.location,deaths.population, vac.new_vaccinations
FROM PortfolioProject.dbo. CovidDeaths deaths
JOIN PortfolioProject.dbo. CovidVaccinations Vac
    ON deaths.location = vac.location
	AND deaths.date = vac.date
	WHERE deaths.continent IS NOT null
	ORDER BY 2,3;

	-- Total number of Vaccinations on rolling basis 

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated_rolling
FROM PortfolioProject.dbo. CovidDeaths deaths
JOIN PortfolioProject.dbo. CovidVaccinations Vac
    ON deaths.location = vac.location
	AND deaths.date = vac.date
	WHERE deaths.continent IS NOT null 
	ORDER BY 2,3;

-- USE CTE to Get percentatge of people getting vaccinated daily in different countries  

WITH PopulationvsVaccination (continent, location, date, population, New_vaccinations, TotalPeopleVaccinated_rolling)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated_rolling
FROM PortfolioProject.dbo. CovidDeaths deaths
JOIN PortfolioProject.dbo. CovidVaccinations Vac
    ON deaths.location = vac.location
	AND deaths.date = vac.date
	WHERE deaths.continent IS NOT null 
)
SELECT *, (TotalPeopleVaccinated_rolling / population)*100
FROM PopulationvsVaccination; 

--CREATE TEMP TABLE to Get percentatge of people getting vaccinated daily in different countries

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalPeopleVaccinated_rolling numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated_rolling
FROM PortfolioProject.dbo. CovidDeaths deaths
JOIN PortfolioProject.dbo. CovidVaccinations Vac
    ON deaths.location = vac.location
	AND deaths.date = vac.date
	WHERE deaths.continent IS NOT null 
	ORDER BY 2,3

SELECT *, (TotalPeopleVaccinated_rolling / population)*100
FROM #PercentPopulationVaccinated;


--SQL queries for data used for Visualization in Tableau

--1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


--2
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--3 


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

--5

Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--6
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


--Creating View to store data for later visualization
 --1
CREATE VIEW DeathPercentage AS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null;

SELECT*
FROM DeathPercentage

--2
CREATE VIEW TotalDeathCount AS
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS null AND location NOT IN ('world', 'European Union', 'International')
GROUP BY location

SELECT*
FROM TotalDeathCount

--3

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated_rolling
FROM PortfolioProject.dbo. CovidDeaths deaths
JOIN PortfolioProject.dbo. CovidVaccinations Vac
    ON deaths.location = vac.location
	AND deaths.date = vac.date
	WHERE deaths.continent IS NOT null 



SELECT *
FROM PercentPopulationVaccinated

--4

CREATE VIEW TotalInfectionPercentage AS
SELECT location, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS TotalInfectionPercentage
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population, date 

SELECT *
FROM TotalInfectionPercentage


--5

CREATE VIEW CountriesHighestDeathCount AS
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
GROUP BY location;

SELECT*
FROM CountriesHighestDeathCount


--6

CREATE VIEW ContinentsHighestDeathCount AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject.dbo. CovidDeaths
WHERE continent IS NOT null
GROUP BY continent;

SELECT*
FROM ContinentsHighestDeathCount

--7 

CREATE VIEW TotalPeopleVaccinated_rolling AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS TotalPeopleVaccinated_rolling
FROM PortfolioProject.dbo. CovidDeaths deaths
JOIN PortfolioProject.dbo. CovidVaccinations Vac
    ON deaths.location = vac.location
	AND deaths.date = vac.date
	WHERE deaths.continent IS NOT null;

SELECT*
FROM TotalPeopleVaccinated_rolling

