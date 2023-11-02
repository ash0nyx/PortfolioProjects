Select *
From PortfolioProject3..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject3..CovidVaccinations
--order by 3,4

-- Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject3..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deahts
--Shows likelihood of dying if you contract covid in France

Select Location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject3..CovidDeaths
Where location like '%France%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of Population got Covid

Select Location, date, population, total_cases, 
total_cases/ population*100 as PercentPopulationInfected
From PortfolioProject3..CovidDeaths
--Where location like '%France%'
Where continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as HighestInfectionCount, 
max((total_cases/ population))*100 as PercentPopulationInfected
From PortfolioProject3..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject3..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Let's break things down by continent


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject3..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject3..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject3..CovidDeaths
Where continent is not null
order by 1,2


-- Let's take a look at Vaccinations


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/)
From PortfolioProject3..CovidDeaths dea
Join PortfolioProject3..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2, 3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject3..CovidDeaths dea
Join PortfolioProject3..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject3..CovidDeaths dea
Join PortfolioProject3..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visulizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject3..CovidDeaths dea
Join PortfolioProject3..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated