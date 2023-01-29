/****** Script for SelectTopNRows command from SSMS  ******/
Select Location, date, total_cases, new_cases, total_deaths, population
 FROM [portfolioProject].[dbo].[CovidDeaths (1)]
Where continent is not null 
order by 1,2

 -- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portfolioProject].[dbo].[CovidDeaths (1)]
Where location like '%india%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date,population,total_cases,(total_cases/population)*100 as Infection_rate
From [portfolioProject].[dbo].[CovidDeaths (1)]
Where location like '%india%'
and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location,population,max(total_cases) as highest_TotalCases,max(total_cases/population)*100 as highest_Infection_rate
From [portfolioProject].[dbo].[CovidDeaths (1)]
Where continent is not null 
group by Location,population
order by 4 desc,1,2

-- Countries with Highest Death Count per Population
Select Location, population,max (total_deaths) as Highest_deathCount,max (total_deaths/population)*100 as death_rate
 FROM [portfolioProject].[dbo].[CovidDeaths (1)]
Where continent is not null 
group by Location, population
order by 4 desc,1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over(partition by d.location order by d.date  ) as total_vaccination
from
 [portfolioProject].[dbo].[CovidDeaths (1)] as d
join [portfolioProject].[dbo].[CovidVaccinations] as v on d.Location=v.location and d.date=v.date
where d.continent is not null 
order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over(partition by d.location order by d.date  ) as total_vaccination
from
 [portfolioProject].[dbo].[CovidDeaths (1)] as d
join [portfolioProject].[dbo].[CovidVaccinations] as v on d.Location=v.location and d.date=v.date
where d.continent is not null
--order by 1,2
)
select * ,(RollingPeopleVaccinated/Population) as vaccination_rate
from PopvsVac
where Location='india'


--Create View
create view PercentPopulationVaccinated as
(select d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over(partition by d.location order by d.date  ) as total_vaccination
from
 [portfolioProject].[dbo].[CovidDeaths (1)] as d
join [portfolioProject].[dbo].[CovidVaccinations] as v on d.Location=v.location and d.date=v.date
where d.continent is not null)


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolioProject].[dbo].[CovidDeaths (1)]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


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
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over(partition by d.location order by d.date  ) as total_vaccination
from
 [portfolioProject].[dbo].[CovidDeaths (1)] as d
join [portfolioProject].[dbo].[CovidVaccinations] as v on d.Location=v.location and d.date=v.date
where d.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by location,date 