Select *
From PortfolioProject..['CovidDeaths']
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..['CovidVaccinations']
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths']
Where continent is not null
order by 1,2

--Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
Where location like '%states%' and continent is not null
order by 1,2

--Total Cases vs Population
Select Location, date, population, total_cases, (total_cases/population) * 100 as CasePercentage
From PortfolioProject..['CovidDeaths']
Where location like '%states%' and continent is not null
order by 1,2

--Countries with Highest Infection Rate
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as InfectionRate
From PortfolioProject..['CovidDeaths']
Where continent is not null
Group by Location, population
order by InfectionRate desc

--Countries with Most Deaths
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Continents with Most Deaths (data not correct! 38 min mark in video)
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers, Daily Cases vs. Daily Deaths
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
Where continent is not null
Group by date
order by 1,2

--Global Numbers, Total Cases vs Total Deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
Where continent is not null
order by 1,2


--Vaccination Rate relative to World Population
--Use CTE
With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, total_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinated
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
Select *, (total_vaccinated/population)*100
From PopvsVacc

--Vaccination Rate relative to World Population
--Use Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
total_vaccinated numeric
)
Insert into #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinated
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select *, (total_vaccinated/population)*100 as percentage_vaccinated
From #PercentPopulationVaccinated

--Views
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinated
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated