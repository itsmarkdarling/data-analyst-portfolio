select * from PortfolioProject..covid_deaths
where continent is not null

-- select data
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
order by 1,2;

-- looking at total cases vs total deaths

select location, date, total_cases, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..covid_deaths
where location like '%states%'
order by 1,2


-- looking at total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
from PortfolioProject..covid_deaths
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as 
	Percent_Population_Infected
from PortfolioProject..covid_deaths
group by location, population
order by Percent_Population_Infected

-- showing countries with highest death count per population

select location, MAX(CAST(total_deaths as int)) as Total_Death_Count
from PortfolioProject..covid_deaths
-- where location like '%states%'
where continent is null
group by location
order by Total_Death_Count desc


-- Global Numbers

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProject..covid_deaths
where continent is not null
--where location like '%states%'
--group by date
order by 1,2



-- looking at total population vs vaccinations

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as percentage
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac




-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as percentage
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




-- Creating View to store data for visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as percentage
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated