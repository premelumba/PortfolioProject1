-- Looking at coviddeaths table
SELECT *
FROM coviddeaths
Where continent is not null
Order by 3,4;

--Looking at covidvaccinations table
SELECT *
FROM covidvaccinations
Order by 3,4;

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths 
--Question you want to answer: what is the percent of death per total cases? 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From coviddeaths
Where location = 'United States'
Order by 1,2

--It is interesting that May 2020 the United States saw its greatest percent of death per total cases at 6.12%
--Although total deaths continued to increase the percent of death per total cases decreased, April 2024 it is 1.14%


-- Looking at Total cases vs. population
-- Shows what percentage of population has gotten COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From coviddeaths
Where location = 'United States'
Order by 1,2

--Percent of United States population that has gotten COVID by April 21, 2024 when this data was collected is approximately 30.6%

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From coviddeaths
--Where location = 'United States'
GROUP BY location, population
Order by PercentPopulationInfected desc;

--Cyprus has the highest infection rate compared to population at 77.1% in 4/2024

--Showing Countries with the Highest Death Count 
SELECT location, Max(Total_deaths)as MaxDeathCount
From coviddeaths
Where total_deaths is not null
GROUP BY location
Order by MaxDeathCount desc;

--United States had highest death count 

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continent with the highest death count

SELECT continent, Max(Total_deaths)as MaxDeathCount
From coviddeaths
Where continent is not null
GROUP BY continent
Order by MaxDeathCount desc;

---Global Numbers: Daily New Cases and New Death Percentage
SELECT date, SUM (Distinct new_cases) as total_new_cases, SUM (distinct new_deaths)as total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS New_DeathPercentage
From coviddeaths
--Where location = 'United States'
Where new_cases >= 1
Group By date
Order by 1,2


--Global Numbers: Daily Total_cases and Daily Total_deaths
--Global death percentage

SELECT date, SUM(total_cases) as total_cases, SUM(total_deaths) as total_deaths, SUM(total_deaths)/SUM(total_cases)*100 AS Global_DeathPercentage
From coviddeaths
--Where location = 'United States'
Where continent is not null
Group By date
Order by 1,2

--- Numbers in China: Total_deaths and Total_cases in China
Select date, sum(total_cases)as total_cases_china, sum (total_deaths) as total_deaths_china
From coviddeaths
where location = 'China'
Group By date, total_cases, total_deaths

--Which countries had covid_cases in 01/2020

Select date, location, total_cases
FROM coviddeaths
Where total_cases >0
Group By date, location, total_cases
Order by date;

--Global Numbers: total cases 
-- Sum total of new cases globally, Sum total of deaths globally

SELECT SUM (Distinct new_cases) as total_new_cases, SUM (distinct new_deaths)as total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS New_DeathPercentage
From coviddeaths
--Where location = 'United States'
Where new_cases >= 1
--Group By date
Order by 1,2


--Join both coviddeaths table and covidvaccinations table

SELECT *
From coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	
--Looking at Total Population Vs. Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

---Rolling People Vaccinated: Daily totals of people vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

---Looking at population who are vaccinated
--percent of population that are vaccinated
--Use CTE

With PopvsVac AS(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)
Select Continent, location, date, population, new_vaccinations, rolling_people_vaccinated, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
FROM PopvsVac
 
--Create TEMP TABLE
--This table looks the same as the one above

DROP TABLE if exists PercentPopulationVaccinated;
CREATE Table PercentPopulationVaccinated
(
Continent varchar (40),
Location varchar (40),
date date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date;
--Where dea.continent is not null
 
Select Continent, location, date, population, new_vaccinations, rolling_people_vaccinated, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
FROM PercentPopulationVaccinated

--Creating Views to store data for later visualizations


Create view Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null;

--Create other views based on information above
