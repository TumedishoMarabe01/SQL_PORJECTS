CREATE DATABASE PortfolioProject

SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null

SELECT * 
FROM PortfolioProject..CovidVaccinations

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--Total cases vs Total deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
where Location like '%states%'
ORDER BY 1,2

--Total cases vs Population
--Shows percentage of population that had Covid
SELECT Location, date, Population, total_cases, (total_cases/Population) * 100 AS Have_Covid
FROM PortfolioProject..CovidDeaths
where Location like '%south africa%'
ORDER BY 1,2

SELECT Location, date, Population, total_cases, (total_cases/Population) * 100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
--where Location like '%south africa%'
ORDER BY 1,2


--Countries with the highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) Highest_Infection_Count, MAX((total_cases/Population)) * 100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY Location, Population
ORDER BY PercentOfPopulationInfected DESC


--Countries with the highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Continents highest death rate 
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers sorting by date showing new cases, total deaths everyday and calculates the total deaths percentage
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Calculates the entire death percentage of the world
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Population vs Vaccincations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(Partition by cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cv.location = cd.location
AND cv.date = cd.date
WHERE cd.continent is not null
ORDER BY 1,2,3

--USE CTE since we are getting an error due to the column we created 
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(Partition by cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cv.location = cd.location
AND cv.date = cd.date
WHERE cd.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopVsVac

--Temp table
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(Partition by cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cv.location = cd.location
AND cv.date = cd.date

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

--Views to store data for later visulations
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(Partition by cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
ON cv.location = cd.location
AND cv.date = cd.date
WHERE cd.continent is not null

SELECT *
FROM PercentPopulationVaccinated

