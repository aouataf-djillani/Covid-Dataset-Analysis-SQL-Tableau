/** Let's assume a simple schema consisting of two tables.

STATISTICS for COVID-19 daily statistics like confirmed cases, deaths, etc.
DEMOGRAPHICS with addition per-country data like population, area, population density and more
STATISTICS
This table could have columns such as

country_id: Identifies the country by ISO code
dt: the date for the reported number
confirmed_cases: number of confirmed cases
deaths: number of confirmed deaths
...
Data could come from a source like https://www.ecdc.europa.eu/en/geographical-distribution-2019-ncov-cases or https://www.who.int/emergencies/diseases/novel-coronavirus-2019

DEMOGRAPHICS
This table could have columns such as

country_id: identifies the country by ISO code
country_name: the full country name
population: total population
area: total area
density: population density
...
There could be many more columns. See https://unstats.un.org/unsd/demographic-social/index.cshtml for a possible data source. **/ 

use Covid20;
-- Data Cleaning: 
-- Deleting non useful  records where location
-- is defined by continent and continent column is empty 

delete from covid where continent= ' ';

select * from covid;


-- convert data types
 
ALTER TABLE Covid 
ALTER COLUMN population float

ALTER TABLE Covid
ALTER COLUMN total_cases float
 
ALTER TABLE Covid
ALTER COLUMN total_deaths float
ALTER TABLE Covid
ALTER COLUMN new_deaths float
ALTER TABLE Covid
ALTER COLUMN diabetes_prevalence float


-- Current Infection rate around the world 
select date, location, total_cases/population as infection_rate 
from Covid
where date in ( select max(date) from Covid);

-- Current Vaccinations Rate in Australia and France  
select location,
population,
people_vaccinated, 
round(people_vaccinated/population, 2) as vaccination_rate, 
total_cases/population as infection_rate, 
total_deaths/population as death_rate
from Covid
where date in (select max(date) from Covid) and location in ('France', 'Australia'); 

-- Vaccination rate per population in France and Australia
select date, location, population, people_vaccinated, round(people_vaccinated/population, 5) as vaccination_rate 
from Covid
where location in ('France', 'Australia');

-- Death count in different continents

Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid
Group by continent
order by TotalDeathCount desc
-- Total cases per month in Australia 
select format(date, 'MM-yy') as Month, count(new_cases) as total_cases
from Covid 
group by format(date, 'MM-yy')
order by format(date, 'MM-yy')
; 

-- Daily total death risk in the world  
select format(date,'dd-MM-yy') as date,round(sum(cast(new_deaths as bigint))/sum(NULLIF(new_cases, 0))*100, 5) as death_risk
from Covid
group by date;
-- Countries with highest death count each day 

select format(t1.date, 'dd-MM-yy') as date, t1.location, t1.new_deaths 
from Covid t1 
inner join (select date, max(new_deaths) as maxVax from Covid group by date) t2
on t1.date=t2.date and t1.new_deaths =t2.maxVax;

-- Tracking and comparing daily rate of total vaccinations per population in France and Australia

select date,
location, 
population, 
sum(cast(new_vaccinations as int)) over (partition by location order by date) as total_vaccinations
from Covid
where location in ('France', 'Australia') 
order by location, date; 

-- Death risk in Australia 
Select Location, date, (total_deaths/total_cases)*100 as Death_risk
From Covid
where location= 'Australia'
order by 1,2
;

-- daily infection rate in Australia and France 
-- total cases/population*100
select  format(date,'dd-MM-yy') as date, Location, round((total_cases/population)*100, 5) as infection_rate
from Covid
where Location in ('France','Australia') 
; 


-- Highest Infection Rate ever for each country (per Population)

select location,  round(max((total_cases/population))*100,5)  as highest_infection_rate
from Covid
group by location
order by highest_infection_rate DESC
; 


-- Dates where France had the highest number of new deaths
select t1.date, t1.location, t1.new_deaths 
from Covid t1 
inner join (select date, max(new_deaths) as maxVax from Covid group by date) t2
on t1.date=t2.date and t1.new_deaths =t2.maxVax
where location='France'
order by date;

-- Highest death rate ever (per population) for each country 
select location, round(max(total_deaths/population)*100,5) as highest_death_rate
from Covid
group by location
order by location;

-- Highest death count for each continent
select continent, max(total_deaths) as highest_death_count
from Covid
group by continent
order by continent;

-- Total new cases around the world per day 
select date,sum(new_cases) as total_cases
from Covid
group by date; 

-- Total new deaths in the world per day 
select date,sum(cast(new_deaths as int)) as total_deaths
from covid
group by date; 



-- Tracking new vaccinations in France, Australia and the US
-- Showing Percentage of Population that has recieved at least one Covid Vaccine 

select date, location, population, new_vaccinations, new_vaccinations/population as vaccination_rate 
from Covid
where location in ('France', 'Australia') 
and cast(new_vaccinations as int ) >=1
order by location, date; 











