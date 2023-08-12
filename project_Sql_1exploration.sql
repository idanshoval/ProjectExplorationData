 
 --Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- Select Data that we are going to be starting with
select D.location,d.date,d.total_cases,d.new_cases,d.total_deaths,d.population
from CovidDeaths D
where d.continent is not null 
order by 1,2

--Looking of total cases vs total deaths
--Shows the probability of dying  from covid
select d.location,d.total_cases ,d.total_deaths as 'total death',(convert(float,d.total_deaths)/d.total_cases)*100 as precentge_death,d.date
from CovidDeaths D
where D.location LIKE '%state%'  and d.continent is not null 
order by 1,2


--Countries with highest infection rate compared to population 
select d.location ,max((convert(float,d.total_cases)/d.population))*100 as 'infection rate'
from CovidDeaths D
where d.continent is not null 
group by d.location,d.population
order by 'infection rate' desc



-- showing the country  with the highest  death count 
select d.location,max(convert(int,d.total_deaths)) as max_totaldeath
from CovidDeaths D
where d.continent is not null 
group by d.location
order by max_totaldeath desc

---Showing contintents with the highest death count per population
select d.continent,max(convert(int,d.total_deaths)) as max_totaldeath
from CovidDeaths D
where d.continent is not null 
group by d.continent
order by max_totaldeath desc


--showing by date the percent of death  
select d.date ,sum(d.new_cases) daycases,sum(convert(float,d.new_deaths)) /sum(d.new_cases)*100 as 'percent deaths day'
from CovidDeaths D
where d.continent is not null and d.new_cases is not null and d.new_cases<>0 and d.new_deaths is not null
group by d.date
order by 'percent deaths day'
 
-- global number 
select  sum(d.new_cases) as cases,sum(convert(float,d.new_deaths)) as Total_death,sum(convert(float,d.new_deaths)) /sum(d.new_cases)*100 as 'percent deaths'
from CovidDeaths D
where d.continent is not null



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

--option 1
--using cte for dispaly ratio between cumulative vaccinations to population
with cte_ratio_vaccinations_population(continent,location,date,population,vaccinations_per_day,rollingpeople_vaccnitated)
as(
select c.continent,c.location,c.date,c.population,v.new_vaccinations  as vaccinations_per_day,
sum(convert(float,v.new_vaccinations)) over (partition by c.location order by c.location, c.date) as rollingpeople_vaccnitated
from  CovidDeaths  C  inner join  CovidVaccinationTable V ON C.location=V.location and c.date=v.date
where  c.continent is not null
)


--display  ratio between cumulative vaccinations and  population
select *,(c.rollingpeople_vaccnitated/c.population)*100 as 'ratio'
from cte_ratio_vaccinations_population c
where c.rollingpeople_vaccnitated is not null
order by c.location

--option 2 temp table 
select c.continent,c.location,c.date,c.population,v.new_vaccinations  as vaccinations_per_day,
sum(convert(float,v.new_vaccinations)) over (partition by c.location order by c.location, c.date) as rollingpeople_vaccnitated  into #temptable
from  CovidDeaths  C  inner join  CovidVaccinationTable V ON C.location=V.location and c.date=v.date
where  c.continent is not null


select *,(#temptable.rollingpeople_vaccnitated/#temptable.population) as 'ratio'
from  #temptable 


--- create view to store data for visualization
create view viewtable  as
select c.continent,c.location,c.date,c.population,v.new_vaccinations  as vaccinations_per_day,
sum(convert(float,v.new_vaccinations)) over (partition by c.location order by c.location, c.date) as rollingpeople_vaccnitated 
from  CovidDeaths  C  inner join  CovidVaccinationTable V ON C.location=V.location and c.date=v.date
where  c.continent is not null

-- show view result
select *
from viewtable