-- Order By 3 ,4 meaning we are getting result by ascending 3rd and 4th columns of the table 

SELECT *
FROM CovidDeaths
--where continent is not NULL
order by 3,4;

SELECT *
FROM CovidVaccinations
order by 3,4;

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2; 

-- Looking at total cases vs total deaths. How many cases in a country and how many deaths they have for their entire cases
-- We want to know the percentage of people who are dying or infected
-- It shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (cast (total_deaths as float) /total_cases)*100 AS DeathPercentage
FROM CovidDeaths
ORDER BY 1,2; 
-- Meaning 'Afghanistan	2021-04-30	59745	2625	4.393673110720562' there is 4% chance of dying if you live in AFG on that particular date.

-- If you want to see data of only "United States"
SELECT location, date, total_cases, total_deaths, (cast (total_deaths as float) /total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2; 

-- Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (cast (total_cases as float) /population)*100 AS CovidPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2; 

-- Looking at countries with highest infection rate compared to population

SELECT location, population, max (total_cases) AS HighestInfection, max((cast (total_cases as float) /population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY population, location
ORDER BY PercentPopulationInfected desc;

-- Showing countries with highest death counts per population
SELECT location, max (total_deaths) AS HighestDeathCount
FROM CovidDeaths
GROUP BY location
ORDER BY HighestDeathCount desc;
-- By executing above query we get output where location value contains 'Asia', 'World' etc. This happened coz continent for them is null.
-- To remove that we can add one more statement  where continent is not null.
-- So we made changes in above queries also
SELECT location, max (total_deaths) AS HighestDeathCount
FROM CovidDeaths
where continent is not NULL
GROUP BY location
ORDER BY HighestDeathCount desc;

-- Wrting same query but by breaking down by Continent
-- The output of this query is not perfect coz the count of North America is equal to USA. It didn't included Canada
SELECT continent, max (total_deaths) AS HighestDeathCount
FROM CovidDeaths
where continent is not NULL
GROUP BY continent
ORDER BY HighestDeathCount desc;
-- We are going to follow above approach just to go on with the project

-- Second Approach not considered
--SELECT location, max (total_deaths) AS HighestDeathCount
--FROM CovidDeaths
--where continent is NULL
--GROUP BY location
--ORDER BY HighestDeathCount desc;

-- Showing the continents with highest death count per population(which is nothing but above statement)
SELECT continent, max (total_deaths) AS HighestDeathCount
FROM CovidDeaths
where continent is not NULL
GROUP BY continent
ORDER BY HighestDeathCount desc;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Now we will work on global numbers
-- Below query is for total number of cases and deaths on a particular date( Meaning here we are considering all numbers from all locations)

-- Below query is giving total count of new cases and new deaths for each date
SELECT date, sum(new_cases) as total_new_cases , sum(new_deaths) as total_new_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100)  as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2;

-- Below query is giving total count of new cases and new deaths for both years
SELECT DATEPART(year, date) as groupbymonth, sum(new_cases) as total_new_cases , sum(new_deaths) as total_new_deaths , (sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100)  as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL 
GROUP BY DATEPART(year, date) 
ORDER BY 1,2;

-- Below query is giving total count of new cases and new deaths for each month of year 2020.
SELECT DATEPART(MONTH, date) as groupbymonth, sum(new_cases) as total_new_cases , sum(new_deaths) as total_new_deaths , (sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100)  as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL and  YEAR (date)= 2021
GROUP BY DATEPART(MONTH, date) 
ORDER BY 1,2;

-- Below query is for total new cases and new deaths all over the globe
SELECT sum(new_cases) as total_new_cases , sum(new_deaths) as total_new_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100)  as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2;
-- Apply above procedure for two remaining queries

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Now we will join two table CovidDeaths and CovidVaccination

-- Looking at total population vs vaccination
SELECT Cd.continent , Cd.location, Cd.date, Cd.population, Cv.new_vaccinations
FROM CovidDeaths as Cd
JOIN CovidVaccinations as Cv
on Cd.location = Cv.location and Cd.date = Cv.date
WHERE Cd.continent is not NULL
ORDER BY 2,3;

-- If you want to find rolling vaccination number for each location then you can achieve that by using Partition
SELECT Cd.continent , Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
SUM(cast(Cv.new_vaccinations as int)) OVER (PARTITION BY Cd.location ORDER BY Cd.location , Cd.date) as RollingPeopleVaccinated
FROM CovidDeaths as Cd
JOIN CovidVaccinations as Cv
on Cd.location = Cv.location and Cd.date = Cv.date
WHERE Cd.continent is not NULL
ORDER BY 2,3;

-- Now we need to find total population vs vaccination
SELECT Cd.continent , Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
SUM(cast(Cv.new_vaccinations as int)) OVER (PARTITION BY Cd.location ORDER BY Cd.location , Cd.date) as RollingPeopleVaccinated
FROM CovidDeaths as Cd
JOIN CovidVaccinations as Cv
on Cd.location = Cv.location and Cd.date = Cv.date
WHERE Cd.continent is not NULL
ORDER BY 2,3;

-- Now we need to use alias column 'RollingPeopleVaccinated' to ccalculate total population vs vaccination. 
-- For that we are using CTE (Common Table Expression) which is by creating temp table.

WITH TempTable (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS (SELECT Cd.continent , Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
    SUM(cast(Cv.new_vaccinations as int)) OVER (PARTITION BY Cd.location ORDER BY Cd.location , Cd.date) as RollingPeopleVaccinated
    FROM CovidDeaths as Cd
    JOIN CovidVaccinations as Cv
    on Cd.location = Cv.location and Cd.date = Cv.date
    WHERE Cd.continent is not NULL
    )
SELECT * , RollingPeopleVaccinated / cast (population as float) * 100
FROM TempTable;

-- Creating view to store data for later visulaizations

CREATE VIEW PercentPopulationVaccinated AS 
(SELECT Cd.continent , Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
SUM(cast(Cv.new_vaccinations as int)) OVER (PARTITION BY Cd.location ORDER BY Cd.location , Cd.date) as RollingPeopleVaccinated
FROM CovidDeaths as Cd
JOIN CovidVaccinations as Cv
on Cd.location = Cv.location and Cd.date = Cv.date
WHERE Cd.continent is not NULL);

SELECT *
FROM PercentPopulationVaccinated;