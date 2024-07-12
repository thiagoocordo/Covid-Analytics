
--Porcentaje de muertos sobre el total de casos en Argentina
Select Location, date, total_cases,total_deaths, (cast (total_deaths as float) / cast (total_cases as float))*100 as DeathPercentage
From CovidDeath
Where location like '%Argentina%'
order by 1,2 

--Porcentaje de personas con COVID en Argentina
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeath
Where location like '%Argentina%'
order by 1,2

--Paises con mas porcentaje de infectados
Select Location,population, max(cast (total_cases as float)) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
where continent is not null
Group by location,population
order by PercentPopulationInfected desc

--Paises con el porcentaje de muertos mas alto
Select Location,max(cast(total_deaths as float)) as total_deaths,
max(cast(population as float)) as population,
MAX(cast(Total_deaths as float)/cast(population as float))*100 as TotalDeathCount
From CovidDeath
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Estadistica global de porcentaje total de muertos
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Numeros Globales
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
where continent is not null 
order by 1,2

--Total Poblacion vs Vacunados
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

------ Porcentaje de Vacuandos
    Select dea.continent, dea.location, max(dea.date) as date ,max(dea.population) as population,
	max(cast(vac.total_vaccinations as float)) as total_vacciantions,
    max(CONVERT(float,vac.people_vaccinated))as RollingPeopleVaccinated
    From CovidDeath dea
    Join CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
    Where dea.continent is not null 
	Group by dea.location,dea.continent
	order by 2 asc

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
total_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
    Select dea.continent, dea.location, max(dea.date) as date ,max(dea.population) as population,
	max(cast(vac.total_vaccinations as float)) as total_vacciantions,
    max(CONVERT(float,vac.people_vaccinated))as RollingPeopleVaccinated
    From CovidDeath dea
    Join CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
    Where dea.continent is not null 
	Group by dea.location,dea.continent
	order by 2 asc

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by Location asc


-- Vista para la Visualizacion
Create View PercentPopulationVaccinated as
    Select dea.continent, dea.location, max(dea.date) as date ,max(dea.population) as population,
	max(cast(vac.total_vaccinations as float)) as total_vacciantions,
    max(CONVERT(float,vac.people_vaccinated))as RollingPeopleVaccinated
    From CovidDeath dea
    Join CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
    Where dea.continent is not null 
	Group by dea.location,dea.continent
