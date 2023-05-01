

Select *
From CovidProject..CovidDeaths
Where continent is not null 
order by 3,4


Select *
From CovidProject..CovidVaccinations
Where continent is not null 
order by 3,4

-- Selecting the Data that's going to require in this analysis

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null 
order by location,date

-- Total Deaths Percentage in India

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where location is not null 
order by location,date, total_cases asc

-- Total Deaths Percentage in India

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%India'
and continent is not null 
order by 1,2

-- Total Population Infected Worldwide

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PopulationInfected
From CovidProject..CovidDeaths
order by 1,2

-- Total Population Infected in India

Select Location, population, date,  round( (total_cases/population)*100,2) as PopulationInfected
From CovidProject..CovidDeaths
where location like '%India'
order by 1,2,3 asc

-- Countries with Highest Infection Rate compared to Population

Select Location, Population,  round(Max((total_cases/population))*100 ,2) as PopulationInfected
From CovidProject..CovidDeaths
Group by Location, Population
order by PopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where location is not null 
Group by Location
order by TotalDeathCount desc

--Countries with highest hospital beds

Select location, max(hospital_beds_per_thousand) as HospitalBeds
From CovidProject..CovidDeaths
Group by location
order by HospitalBeds desc


-- contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Death Percentage globally

Select Continent, Location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null 
group by continent, location
order by 3,4

--From when icu patients started increasing

Select Location, Date, icu_patients 
from CovidProject..CovidDeaths 
where icu_patients is not null

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Countries with highest positive_rate from each continent
--using dense_rank() window function

Select continent, location, Round(positive_rate,0) as PositiveRate,
Rank() over(partition by Location order by round(positive_rate,0)) as Dense_Rank
From CovidProject..CovidDeaths where continent is not null

--which county had the highest average reproduction rate

Select location, avg(round(reproduction_rate,0)) as Rate
From CovidProject..CovidDeaths group by location order by Rate desc

Select * from CovidProject..CovidDeaths;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as Populated
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

