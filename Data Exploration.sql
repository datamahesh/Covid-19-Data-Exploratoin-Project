
-----------Data Exploration Project on Covid-19-----------

select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from 
	CovidDeaths
order by 1,2


----Looking for Total cases vs Total Deaths----

select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 as [Death %]
from 
	CovidDeaths
where 
	location like '%india%'
order by 1,2


----Looking at Total cases vs Ppopulation----

select 
	location,
	date,
	total_cases,
	population,
	(total_cases/population) * 100 as [Cases %]
from 
	CovidDeaths
where 
	location like '%india%'
order by 1,2


----Looking at countries with highest infection rate compared to population----

select 
	location,
	population,
	MAX(total_cases) as [Highest Infection Count],
	MAX((total_cases/population))* 100 as [Population Infected %]
from 
	CovidDeaths
group by 
	location,population
order by [Population Infected %] desc


----Showing countries with highest death count per population----

select 
	location,
	MAX(cast(total_deaths as int)) as [Total Deaths]	
from 
	CovidDeaths
where 
	continent is not null
group by 
	location
order by [Total Deaths]	 desc


----Lets Break Things down by Continent----

select 
	location,
	MAX(cast(total_deaths as int)) as [Total Deaths]	
from 
	CovidDeaths
where 
	continent is null
group by 
	location
order by [Total Deaths]	 desc


----Showing the continent with highest death count per population----

select 
	continent,
	MAX(cast(total_deaths as int)) as [Total Deaths]	
from 
	CovidDeaths
where 
	continent is not null
group by 
	continent
order by [Total Deaths]	 desc


----Global Numbers----

select
	/*date,*/
	SUM(new_cases) as [Total cases],
	SUM(CAST(new_deaths as int)) as [Total deaths],
	(SUM(CAST(new_deaths as int))/SUM(new_cases)) * 100 as [Death %]
from 
	CovidDeaths
where 
	continent is not null
/*group by 
	date*/
order by 1,2



----Looking at Tota Population Vs Vaccinations----

select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) over (partition by dea.location order by dea.location,
	dea.date) as [Rolling People Vaccinated]
from 
	CovidDeaths dea
	join
	CovidVaccinations vac
on
	dea.location = vac.location
	and dea.date = vac.date
where 
	dea.continent is not null
order by 
	2,3


----CTE----

with PopVsVac (continet,location,date,population,new_vaccinations,[Rolling People Vaccinated])
as
(
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) over (partition by dea.location order by dea.location,
	dea.date) as [Rolling People Vaccinated]

from 
	CovidDeaths dea
	join
	CovidVaccinations vac
on
	dea.location = vac.location
	and dea.date = vac.date
where 
	dea.continent is not null
/*order by 
	2,3*/
)
select 
	*, ([Rolling People Vaccinated]/population)*100
from
	PopVsVac


----Temp Table----

drop table if exists #PopVacPercent
create table #PopVacPercent
(
	Continent					nvarchar(255),
	Location					nvarchar(255),
	Date						datetime,
	Population					numeric,
	new_vaccinations			numeric,
	[Rolling People Vaccinated]	numeric
)

insert into #PopVacPercent 
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
	dea.date) as [Rolling People Vaccinated]
from 
	CovidDeaths dea
	join
	CovidVaccinations vac
on
	dea.location = vac.location
	and dea.date = vac.date
where 
	dea.continent is not null

select 
	*, 
	([Rolling People Vaccinated]/population)*100
from
	#PopVacPercent


----Creating View to store data for later visualization----

create view PercentPopVaccinated
as
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
	dea.date) as [Rolling People Vaccinated]
from 
	CovidDeaths dea
	join
	CovidVaccinations vac
on
	dea.location = vac.location
	and dea.date = vac.date
where 
	dea.continent is not null


select 
	*
from
	PercentPopVaccinated











