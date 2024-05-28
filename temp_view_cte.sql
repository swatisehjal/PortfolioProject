Select location, max(cast(total_deaths as int))as deaths
from PortfolioProject.dbo.coviddeaths
where continent is not null
group by location
order by deaths desc

--global number

select date, SUM(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths
from PortfolioProject.dbo.coviddeaths
where continent is not null
group by date


select SUM(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
from PortfolioProject.dbo.coviddeaths
where continent is not null
order by 1,2


--join covid death n vccination table and using cte

WITH Popvsvac (continent,location,date,population,newvaccination,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population) *100 not possible USE CTE or TEMP /TABLE
from coviddeaths dea 
join covidvaccination vac
on dea.location =vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(rollingpeoplevaccinated/population) *100 from Popvsvac

--using temp table
drop table if exists #rollingpopulationvaccinated 
create table #rollingpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
newvaccination numeric,
rollingpeoplevaccinated numeric
)

insert into #rollingpopulationvaccinated

select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population) *100 not possible USE CTE or TEMP /TABLE
from coviddeaths dea 
join covidvaccination vac
on dea.location =vac.location
and dea.date =vac.date
where dea.continent is not null



select *, (rollingpeoplevaccinated/population) *100  from #rollingpopulationvaccinated

--creating view

create view rollingpopulationvaccinated as
select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population) *100 not possible USE CTE or TEMP /TABLE
from coviddeaths dea 
join covidvaccination vac
on dea.location =vac.location
and dea.date =vac.date
where dea.continent is not null



