/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
      ,[new_tests]
      ,[total_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
      ,[new_tests_smoothed_per_thousand]
      ,[positive_rate]
      ,[tests_per_case]
      ,[tests_units]
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated]
      ,[new_vaccinations]
      ,[new_vaccinations_smoothed]
      ,[total_vaccinations_per_hundred]
      ,[people_vaccinated_per_hundred]
      ,[people_fully_vaccinated_per_hundred]
      ,[new_vaccinations_smoothed_per_million]
      ,[stringency_index]
      ,[population_density]
      ,[median_age]
      ,[aged_65_older]
      ,[aged_70_older]
      ,[gdp_per_capita]
      ,[extreme_poverty]
      ,[cardiovasc_death_rate]
      ,[diabetes_prevalence]
      ,[female_smokers]
      ,[male_smokers]
      ,[handwashing_facilities]
      ,[hospital_beds_per_thousand]
      ,[life_expectancy]
      ,[human_development_index]
  FROM [PortfolioProject].[dbo].[CovidDeaths]

  SELECT * FROM CovidDeaths
  Order by 3, 4

  SELECT * FROM CovidVaccinations
  Order by 3, 4

  Select Location, Date, total_cases, new_cases, total_deaths, population
  FROM Coviddeaths
  order by 1, 2

  --Looking at total Cases vs total deaths

  --looking at total cases vs population
  --shows what percentage of population got covid

  Select Location, Date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
  FROM Coviddeaths
  WHERE Location  like '%states%'
  order by 1, 2

  --Looking at countries with highest infection rate compared to population

   Select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
  FROM Coviddeaths
  GROUP BY Location, Population
  order by PercentPopulationInfected DESC

  --Showing countries with highest death count per population

  Select Location, max(cast(total_deaths as int)) as TotalDeathCount
  FROM Coviddeaths
  WHERE Continent is not null
  GROUP BY Location
  order by TotalDeathCount DESC

  --Let's break things down by continent
  --Showing continents with the highest death count per population

  Select Continent, max(cast(total_deaths as int)) as TotalDeathCount
  FROM Coviddeaths
  WHERE Continent is not null
  GROUP BY Continent
  order by TotalDeathCount DESC

  --Global Numbers

 Select sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 FROM Coviddeaths
 --WHERE Location  like '%states%'
 where continent is not null
 order by 1, 2

 --Looking at Total Population vs Vaccations

 SELECT * 
 FROM CovidDeaths dea
 JOIN CovidVaccinations vac
 ON dea.Location=vac.Location 
 AND dea.date=vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,

FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.Location=vac.Location 
AND dea.date=vac.date
WHERE dea.Continent is not null
order by 2, 3

--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.Location=vac.Location 
AND dea.date=vac.date
WHERE dea.Continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac 

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.Location=vac.Loca tion 
AND dea.date=vac.date
WHERE dea.Continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.Location=vac.Location 
AND dea.date=vac.date
WHERE dea.Continent is not null

SELECT *
FROM PercentPopulationVaccinated
