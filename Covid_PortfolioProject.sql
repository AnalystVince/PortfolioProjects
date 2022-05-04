
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

------------------------------------------------------------------------------------------------------------------------------

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

------------------------------------------------------------------------------------------------------------------------------


--Looking at Total Cases vs Population
--Shows what percentage of Population got covid


Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2

------------------------------------------------------------------------------------------------------------------------------


--Looking at Countries with Highest Infection Rate compared to Population


Select location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

------------------------------------------------------------------------------------------------------------------------------

--Showing Countries with Highest Death Count per Population

Select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------------

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing Continents with Highest Death Count per Population


Select continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, 
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, 
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

------------------------------------------------------------------------------------------------------------------------------

--Looking at Total Population vs Vaccinations 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
Order by 2,3

------------------------------------------------------------------------------------------------------------------------------

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

------------------------------------------------------------------------------------------------------------------------------

--TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


------------------------------------------------------------------------------------------------------------------------------


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated

