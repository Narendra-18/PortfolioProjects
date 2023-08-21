SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null --because in the continent column it is null and location itself is given as continent value
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null 
order by 1,2

-- looking at total cases vs Population
-- shows what percentage of population got covid
SELECT location, date, population,total_cases, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as highestinfectioncount,  max((total_cases/population))*100 as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
group by location, population
order by PercentpopulationInfected desc

--showing countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) as totaldeathcount --using cas because total_deaths column have invalid varchar error
FROM PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by totaldeathcount desc

------LETS BREAK THINGS DOWN BY CONTINENT
--SELECT location, max(cast(total_deaths as int)) as totaldeathcount 
--FROM PortfolioProject..CovidDeaths
--where continent is null 
--group by location
--order by totaldeathcount desc

SELECT continent, max(cast(total_deaths as int)) as totaldeathcount 
FROM PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by totaldeathcount desc

--Showing continent with highest death count
SELECT continent, max(cast(total_deaths as int)) as totaldeathcount 
FROM PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by totaldeathcount desc


-- GLOBAL NUMBERS
SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as roolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) 
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as roolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac




--temp table

drop database if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as roolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated




--creating a view for store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as roolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated