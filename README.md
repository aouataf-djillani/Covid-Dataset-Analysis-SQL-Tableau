# Covid Dataset Analysis using SQL and Tableau     
This repository provides some analysis and insights on the **COVID-19** time series dataset using **SQL** to explore our data, identify tendencies and finally visualize our results using **Tableau**.   
## Steps
 1. Data wrangling : Removing empty records and altering datatype eg. nvarchar to float
 2.  Querying and exploring data using SQL on SQL SERVER 
 3. Exporting data and Visualizing it using Tableau public  
## Dataset 
Our Covid dataset  is available [here](https://ourworldindata.org/covid-deaths) 
It contains information about countries: Cases, Deaths, Hospitalization,  Demographics...etc 
|Columns  | details  |
|--|--|
|iso_code  | Country id  |
|Date |date of reported numbers |
| Location |Country  |
| new_cases |number of new cases  |
| Population |number of inhabitant per country    |
| new_vaccination|daily number of vaccinations   |
| new_deaths|daily number of death cases  |

## Insights 
Our exploratory analysis helps getting some insights such as
## Sample queries 
All queries [here.](https://github.com/aouataf-djillani/Covid-Dataset-Analysis-SQL-Tableau/blob/master/DataExploring.sql)
Current Infection rate around the world 
```sql
select date, location, total_cases/population as infection_rate 
from Covid
where date in ( select max(date) from Covid);
```
Current Vaccinations Rate in Australia and France  
```sql
select location,
population,
people_vaccinated, 
round(people_vaccinated/population, 2) as vaccination_rate, 
total_cases/population as infection_rate, 
total_deaths/population as death_rate
from Covid
where date in (select max(date) from Covid) and location in ('France', 'Australia'); 
```

Countries with highest death count each day 

```sql
select format(t1.date, 'dd-MM-yy') as date, t1.location, t1.new_deaths 
from Covid t1 
inner join (select date, max(new_deaths) as maxVax from Covid group by date) t2
on t1.date=t2.date and t1.new_deaths =t2.maxVax;
```
Dates where France had the highest number of new deaths
```sql
select t1.date, t1.location, t1.new_deaths 
from Covid t1 
inner join (select date, max(new_deaths) as maxVax from Covid group by date) t2
on t1.date=t2.date and t1.new_deaths =t2.maxVax
where location='France'
order by date;
```
Tracking and comparing daily rate of total vaccinations per population in France and Australia

```sql

select date,
location, 
population, 
sum(cast(new_vaccinations as int)) over (partition by location order by date) as total_vaccinations
from Covid
where location in ('France', 'Australia') 
order by location, date; 
```
