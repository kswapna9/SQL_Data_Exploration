select * from PortfolioProject..CovidDeaths
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--select data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--1.Looking at total cases vs total deaths and death percentage in a particular country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%india'
and continent is not null
order by 1,2

--2.Looking at total cases vs population, percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location like '%india'
and continent is not null
order by 1,2

--3.Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--4.Showing Countries with Highest Death Count Per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--5.Showing continents with the highest death count per population  

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--6.Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as  
total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--7.Looking at Total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


--USE CTE

With PopvsVac(continent, location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--8.creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Drop view PercentPopulationVaccinated












