select *
From PortfolioProject1.dbo.CovidDeaths
order by 3,4

select *
from PortfolioProject1..CovidVaccination
order by 3,4

-- Selecting Data to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2

-- looking at the total cases VS the total deaths.
-- show the likehood of dying if you contract covid in Kenya
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From PortfolioProject1..CovidDeaths
where location like '%kenya%'
order by 1,2

-- looking at the total cases VS population
-- show the percentage of population that got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as percentage_with_covid
From PortfolioProject1..CovidDeaths
--where location like '%kenya%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestinfectionCount, MAX((total_cases/population))*100 as percentage_with_covid
From PortfolioProject1..CovidDeaths
--where location like '%kenya%'
Group by location, population
order by percentage_with_covid desc

-- showing the countries with the highest Death count per population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject1..CovidDeaths
--where location like '%kenya%'
where continent is not null
Group by location
order by Total_Death_Count desc

-- Now breaking things to Continent

-- showing the continent with the highest death counts 

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject1..CovidDeaths
--where location like '%kenya%'
where continent is not null
Group by continent
order by Total_Death_Count desc


-- GLOBAL Numbers

select SUM(new_cases)as Total_cases, SUM(cast(new_deaths as int)) as Total_Death, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as Death_Percentage
From PortfolioProject1..CovidDeaths
-- Where location like '%kenya%'
where continent is not null
--Group By date
Order By 1,2


-- Looking at total population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)as Rolling_People_Vaccicated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With popvsVac (continent, location, date, population, New_Vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)as Rolling_People_Vaccicated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingpeopleVaccinated/population)*100
From popvsVac


-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)as Rolling_People_Vaccicated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingpeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)as Rolling_People_Vaccicated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated