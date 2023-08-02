SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--Select the data we are going to bee using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if contract covid in your country
SELECT location, date, total_cases,total_deaths,(CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location Like '%India%' AND continent IS NOT NULL
ORDER BY 1,2
 
----Looking at Total Cases vs Total Deaths
--SELECT location, date, total_cases,total_deaths,(cast(total_deaths as decimal(18, 2))/CAST(total_cases as decimal(18, 2)))*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location Like '%states%'
--ORDER BY 1,2

--Looking at Total Cases vs Population
--shows percentage of population got covid
SELECT location,date,population,total_cases,(CAST(total_cases as float)/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location Like '%India%' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infecttion Rate compared to Population
SELECT location,population,max(cast(total_cases as float)) as HighestInfectionCount, MAX((CAST(total_cases as float)/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
--HAVING location LIKE '%india%'
ORDER BY PercentPopulationInfected desc


--Showing Countries with Highest Death Count Per Population
SELECT location,MAX(CAST(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location					--	in Location Column, Continent names are present and their respective row, continent column is NULL, to get rid of continents present in location...WHERE continent IS NOT NULL
ORDER BY TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with Highest Death Count Per Population
SELECT continent,MAX(CAST(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent							--but these numbers are not correct
ORDER BY TotalDeathCount DESC

--showing Continents with Highest Death Count per population
--SELECT location,MAX(CAST(total_deaths as float)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS  NULL						--numbers are correct but in but some different continent are present
--GROUP BY location
--ORDER BY TotalDeathCount DESC


--Looking at Total Cases of continent vs Population of continent
--shows percentage of population got covid across each continent
SELECT continent,SUM(population) as TotContPopulation,SUM(CAST(total_cases as float)) as Total_cases_cont,(SUM(CAST(total_cases as float))/SUM(population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentPopulationInfected

--Looking at Total Cases of continent vs Total Deaths of continent
SELECT continent,SUM(CAST(total_cases as float)) as Total_cases_cont,SUM(CAST(total_deaths as float)) as Tot_Death_cont,(SUM(CAST(total_deaths as float))/SUM(CAST(total_cases as float)))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage desc


--GLOBAL NUMBERS 

--across the world death percentage date wise
SELECT date,SUM(new_cases) as Total_cases,SUM(CAST(new_deaths as float)) as total_deaths,SUM(CAST(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases != 0 
GROUP BY date
ORDER BY 1,2

--across the world death percentage
SELECT SUM(new_cases) as Total_cases,SUM(CAST(new_deaths as float)) as total_deaths,SUM(CAST(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases != 0 
--GROUP BY date
ORDER BY 1,2

--Joining the Two tables
SELECT *
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date

--Looking at Total Population vs Vaccinations
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
		SUM(CONVERT(float,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated,Vac.total_vaccinations
	--	,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL --AND dea.location LIKE '%INDIA%' 
ORDER BY 2,3


--Use CTE

WITH PopvsVac (continent,location,date,population,new_vaccination,total_vaccination,RollingPeopleVaccinated)									--in CTE, there must be same number of Columns in the WiTH clause and with inside
AS
(
	SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
		SUM(CONVERT(float,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated,Vac.total_vaccinations
	FROM PortfolioProject..CovidDeaths Dea
	JOIN PortfolioProject..CovidVaccinations Vac
		ON Dea.location = Vac.location
		AND Dea.date = Vac.date
	WHERE Dea.continent IS NOT NULL --AND dea.location LIKE '%INDIA%' 
	--ORDER BY 2,3														--The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.

)

--Looking at Total Population vs Vaccinations
SELECT *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PopvsVac
ORDER BY location,date



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
total_vaccination numeric	)

INSERT INTO #PercentPopulationVaccinated					--inserting data from another table
	SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
		SUM(CONVERT(float,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated,Vac.total_vaccinations
	FROM PortfolioProject..CovidDeaths Dea
	JOIN PortfolioProject..CovidVaccinations Vac
		ON Dea.location = Vac.location
		AND Dea.date = Vac.date
	WHERE Dea.continent IS NOT NULL --AND dea.location LIKE '%INDIA%' 
	ORDER BY 2,3

--For Looking at Total Population vs Vaccinations	
SELECT *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated



--Creating VIEW to store data for visulization
DROP VIEW IF EXISTS PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated 
AS
	SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
		SUM(CONVERT(float,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated,Vac.total_vaccinations
	FROM PortfolioProject..CovidDeaths Dea
	JOIN PortfolioProject..CovidVaccinations Vac
		ON Dea.location = Vac.location
		AND Dea.date = Vac.date
	WHERE Dea.continent IS NOT NULL --AND dea.location LIKE '%INDIA%' 
	--ORDER BY 2,3													--The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.

--For Looking at Total Population vs Vaccinations	
SELECT *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PercentPopulationVaccinated



DROP VIEW IF EXISTS WorldDeathPercentage

CREATE VIEW WorldDeathPercentage AS
--across the world death percentage
SELECT SUM(new_cases) as Total_cases,SUM(CAST(new_deaths as float)) as total_deaths,SUM(CAST(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases != 0 
--GROUP BY date
--ORDER BY 1,2

SELECT *
FROM WorldDeathPercentage


	
