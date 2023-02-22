SELECT * 
From PFProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT * 
--From PFProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PFProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PFProject..CovidDeaths
Where location = 'Portugal'
order by 1,2

-- Looking at total cases vs population
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From PFProject..CovidDeaths
Where location = 'Portugal' 
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as MaxInfectedPercentage
From PFProject..CovidDeaths
Where continent is not null
Group By location, population
order by MaxInfectedPercentage desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select location, max(cast(total_deaths as bigint)) as TotalDeathCount
From PFProject..CovidDeaths
Where continent is null
group by location
order by TotalDeathCount desc

-- Showing countries with highest death count per population
Select location, max(cast(total_deaths as bigint)) as TotalDeathCount
From PFProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PFProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select *
From PFProject..CovidVaccinations

-- Total Pop vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PFProject..CovidDeaths dea
Join PFProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
order by 2,3


-- Using a CTE to be able to use the RollingPeopleVaccinated column to perform further calculations

With PopvsVac (continent, location,date,population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PFProject..CovidDeaths dea
Join PFProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PFProject..CovidDeaths dea
Join PFProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PFProject..CovidDeaths dea
Join PFProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
