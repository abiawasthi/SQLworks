select *
from Portfolioproject..covid_death
order by 3,4

--select *
--from Portfolioproject..covid_vaccination
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covid_death
order by 1,2

--Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from covid_death
where location like '%states%'
order by 1,2

--Looking at total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as infectedpercentage
from covid_death
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rates compared to population

select location, population, max(total_cases) as highestInfectionCount, 
max (total_cases/population)*100 as highinfectepercentage
from covid_death
--where location like '%states%'
group by location, population
order by highinfectepercentage desc

-- showing the countries with hishest death count per population

select location, population, max(cast(total_deaths as int)) as totaldeathCount
from covid_death
--where location like '%states%'
where continent is not null
group by location, population
order by totaldeathCount desc

--Break things down by continent

--Continents with highest death counts
select location, max(cast(total_deaths as int)) as totaldeathCount
from covid_death
--where location like '%states%'
where continent is null
group by location
order by totaldeathCount desc

--Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid_death
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--total death percentage globally

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid_death
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination
--,(rolling_vaccination/population)*100

from covid_death dea
join covid_vaccination vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3



-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination
--,(rolling_vaccination/population)*100

from covid_death dea
join covid_vaccination vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_vaccination/population)*100
from PopvsVac




--- TEMP TABLE
Drop table if exists #PercentPopVaccination
Create table #PercentPopVaccination
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)
Insert into #PercentPopVaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination
--,(rolling_vaccination/population)*100

from covid_death dea
join covid_vaccination vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingVaccinations/population)*100
from #PercentPopVaccination


--Create View to store data for later visualizations

Create View PercentPopVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination
--,(rolling_vaccination/population)*100

from covid_death dea
join covid_vaccination vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopVaccination