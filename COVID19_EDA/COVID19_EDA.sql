-- ============================================================
-- COVID-19 Exploratory Data Analysis
-- Database: PortfolioProject
-- Tables: CovidDeaths | CovidVaccinations
-- Author: Mohammed Shameem Sarwar
-- ============================================================

-- ============================================================
-- CHAPTER 1: Data Exploration & Familiarization
-- ============================================================

-- 1.1 Preview both tables
SELECT TOP 10 * 
FROM PortfolioProject..CovidDeaths
ORDER BY location, date

SELECT TOP 10 * 
FROM PortfolioProject..CovidVaccinations
ORDER BY location, date


-- 1.2 Total row counts
SELECT COUNT(*) AS TotalRows_Deaths 
FROM PortfolioProject..CovidDeaths

SELECT COUNT(*) AS TotalRows_Vaccinations 
FROM PortfolioProject..CovidVaccinations


-- 1.3 Date range covered
SELECT 
    MIN(date) AS EarliestDate,
    MAX(date) AS LatestDate,
    DATEDIFF(DAY, MIN(date), MAX(date)) AS TotalDays
FROM PortfolioProject..CovidDeaths


-- 1.4 Distinct countries and continents
SELECT 
    COUNT(DISTINCT location)  AS TotalCountries,
    COUNT(DISTINCT continent) AS TotalContinents
FROM PortfolioProject..CovidDeaths


-- 1.5 List all continents
SELECT DISTINCT continent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY continent


-- 1.6 List all countries per continent
SELECT 
    continent,
    COUNT(DISTINCT location) AS CountryCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY CountryCount DESC


-- 1.7 Check key columns for NULL percentages (Deaths table)
SELECT
    COUNT(*)                                                        AS TotalRows,
    SUM(CASE WHEN total_cases    IS NULL THEN 1 ELSE 0 END) * 100 
        / COUNT(*)                                                  AS Pct_Null_TotalCases,
    SUM(CASE WHEN total_deaths   IS NULL THEN 1 ELSE 0 END) * 100 
        / COUNT(*)                                                  AS Pct_Null_TotalDeaths,
    SUM(CASE WHEN population     IS NULL THEN 1 ELSE 0 END) * 100 
        / COUNT(*)                                                  AS Pct_Null_Population,
    SUM(CASE WHEN continent      IS NULL THEN 1 ELSE 0 END) * 100 
        / COUNT(*)                                                  AS Pct_Null_Continent
FROM PortfolioProject..CovidDeaths


-- 1.8 Check key columns for NULL percentages (Vaccinations table)
SELECT
    COUNT(*)                                                               AS TotalRows,
    SUM(CASE WHEN total_vaccinations IS NULL THEN 1 ELSE 0 END) * 100 
        / COUNT(*)                                                         AS Pct_Null_TotalVaccinations,
    SUM(CASE WHEN people_vaccinated  IS NULL THEN 1 ELSE 0 END) * 100 
        / COUNT(*)                                                         AS Pct_Null_PeopleVaccinated,
    SUM(CASE WHEN new_vaccinations   IS NULL THEN 1 ELSE 0 END) * 100 
        / COUNT(*)                                                         AS Pct_Null_NewVaccinations
FROM PortfolioProject..CovidVaccinations


-- 1.9 Important: continent column contains NULLs when 
--     location = continent name (e.g. 'Asia', 'Europe')
--     Always filter continent IS NOT NULL for country-level analysis
SELECT DISTINCT location
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
ORDER BY location


-- ============================================================
-- CHAPTER 2: Deaths Analysis
-- ============================================================

-- 2.1 Total global cases and deaths
SELECT
    SUM(new_cases)                                    AS TotalCases,
    SUM(CAST(new_deaths AS BIGINT))                   AS TotalDeaths,
    SUM(CAST(new_deaths AS BIGINT)) * 100.0 
        / NULLIF(SUM(new_cases), 0)                   AS GlobalDeathRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


-- 2.2 Total cases, deaths and death rate per country
SELECT
    location,
    MAX(total_cases)                                  AS TotalCases,
    MAX(CAST(total_deaths AS BIGINT))                 AS TotalDeaths,
    MAX(CAST(total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(total_cases), 0)                 AS DeathRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathRate_Pct DESC


-- 2.3 Top 10 countries by total deaths
SELECT TOP 10
    location,
    MAX(CAST(total_deaths AS BIGINT)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC


-- 2.4 Total deaths by continent
SELECT
    continent,
    MAX(CAST(total_deaths AS BIGINT)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC


-- 2.5 Daily death trend globally
SELECT
    date,
    SUM(new_cases)                  AS DailyNewCases,
    SUM(CAST(new_deaths AS BIGINT)) AS DailyNewDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


-- 2.6 Likelihood of dying if infected -- per country
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CAST(total_deaths AS FLOAT) * 100 
        / NULLIF(total_cases, 0)        AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- 2.7 Death percentage for India over time
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CAST(total_deaths AS FLOAT) * 100 
        / NULLIF(total_cases, 0)        AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY date


-- 2.8 Countries with highest death count per population
SELECT
    location,
    population,
    MAX(CAST(total_deaths AS BIGINT))             AS TotalDeaths,
    MAX(CAST(total_deaths AS BIGINT)) * 100.0 
        / NULLIF(population, 0)                   AS DeathsPerPopulation_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathsPerPopulation_Pct DESC


-- ============================================================
-- CHAPTER 3: Infection & Spread Analysis
-- ============================================================

-- 3.1 Infection rate vs population per country
SELECT
    location,
    population,
    MAX(total_cases)                              AS TotalCases,
    MAX(total_cases) * 100.0 
        / NULLIF(population, 0)                   AS InfectionRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate_Pct DESC


-- 3.2 Top 10 most infected countries by infection rate
SELECT TOP 10
    location,
    population,
    MAX(total_cases)                              AS TotalCases,
    MAX(total_cases) * 100.0 
        / NULLIF(population, 0)                   AS InfectionRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate_Pct DESC


-- 3.3 Countries with highest total case count
SELECT TOP 10
    location,
    MAX(total_cases) AS TotalCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalCases DESC


-- 3.4 Daily new cases globally with 7-day rolling average
SELECT
    date,
    SUM(new_cases)                                         AS DailyNewCases,
    AVG(SUM(new_cases)) OVER (
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                                                      AS RollingAvg_7Day
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


-- 3.5 Peak infection date globally
SELECT TOP 1
    date,
    SUM(new_cases) AS DailyNewCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY DailyNewCases DESC


-- 3.6 Infection trend for India specifically
SELECT
    date,
    new_cases,
    total_cases,
    total_cases * 100.0 
        / NULLIF(population, 0)     AS InfectionRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY date


-- 3.7 Countries that never reported cases (data gaps)
SELECT DISTINCT location
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
  AND total_cases IS NULL
ORDER BY location


-- ============================================================
-- CHAPTER 4: Vaccination Rollout Analysis
-- ============================================================

-- 4.1 Total vaccinations per country
SELECT
    location,
    MAX(CAST(total_vaccinations AS BIGINT))     AS TotalVaccinations
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalVaccinations DESC


-- 4.2 Top 10 countries by total vaccinations
SELECT TOP 10
    location,
    MAX(CAST(total_vaccinations AS BIGINT))     AS TotalVaccinations
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalVaccinations DESC


-- 4.3 % of population vaccinated per country
SELECT
    vac.location,
    dea.population,
    MAX(CAST(vac.total_vaccinations AS BIGINT))             AS TotalVaccinations,
    MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
        / NULLIF(dea.population, 0)                         AS VaccinationRate_Pct
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
    ON vac.location = dea.location
    AND vac.date    = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.location, dea.population
ORDER BY VaccinationRate_Pct DESC


-- 4.4 Daily vaccination rollout globally
SELECT
    date,
    SUM(CAST(new_vaccinations AS BIGINT))       AS DailyNewVaccinations
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


-- 4.5 Rolling total vaccinations per country over time
SELECT
    location,
    date,
    new_vaccinations,
    SUM(CAST(new_vaccinations AS BIGINT)) OVER (
        PARTITION BY location
        ORDER BY date
    )                                           AS RollingTotalVaccinations
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY location, date


-- 4.6 India vaccination rollout over time
SELECT
    date,
    new_vaccinations,
    total_vaccinations,
    people_vaccinated,
    people_fully_vaccinated
FROM PortfolioProject..CovidVaccinations
WHERE location = 'India'
ORDER BY date


-- 4.7 Countries that had NO vaccinations recorded
SELECT DISTINCT location
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
  AND total_vaccinations IS NULL
ORDER BY location


-- ============================================================
-- CHAPTER 5: Cross Dataset Joins & Insights
-- ============================================================

-- 5.1 Join both tables -- foundation query
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    dea.total_cases,
    dea.total_deaths,
    vac.total_vaccinations,
    vac.people_vaccinated,
    vac.people_fully_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date    = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date


-- 5.2 Did vaccination reduce deaths?
SELECT
    dea.location,
    dea.population,
    MAX(dea.total_cases)                                      AS TotalCases,
    MAX(CAST(dea.total_deaths AS BIGINT))                     AS TotalDeaths,
    MAX(CAST(dea.total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(dea.total_cases), 0)                     AS DeathRate_Pct,
    MAX(CAST(vac.total_vaccinations AS BIGINT))               AS TotalVaccinations,
    MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
        / NULLIF(dea.population, 0)                           AS VaccinationRate_Pct
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date    = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY VaccinationRate_Pct DESC


-- 5.3 GDP per capita vs death rate
SELECT
    dea.location,
    AVG(dea.gdp_per_capita)                                   AS AvgGDP,
    MAX(CAST(dea.total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(dea.total_cases), 0)                     AS DeathRate_Pct
FROM PortfolioProject..CovidDeaths dea
WHERE dea.continent IS NOT NULL
  AND dea.gdp_per_capita IS NOT NULL
GROUP BY dea.location
ORDER BY AvgGDP DESC


-- 5.4 Life expectancy vs death rate
SELECT
    dea.location,
    AVG(dea.life_expectancy)                                  AS AvgLifeExpectancy,
    MAX(CAST(dea.total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(dea.total_cases), 0)                     AS DeathRate_Pct
FROM PortfolioProject..CovidDeaths dea
WHERE dea.continent IS NOT NULL
  AND dea.life_expectancy IS NOT NULL
GROUP BY dea.location
ORDER BY AvgLifeExpectancy DESC


-- 5.5 Stringency index vs new cases
SELECT
    dea.location,
    dea.date,
    dea.new_cases,
    dea.stringency_index
FROM PortfolioProject..CovidDeaths dea
WHERE dea.continent IS NOT NULL
  AND dea.stringency_index IS NOT NULL
ORDER BY dea.location, dea.date


-- ============================================================
-- CHAPTER 6: Window Functions & Advanced Aggregations
-- ============================================================

-- 6.1 Running total of deaths per country
SELECT
    location,
    date,
    new_deaths,
    SUM(CAST(new_deaths AS BIGINT)) OVER (
        PARTITION BY location
        ORDER BY date
    )                               AS RunningTotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- 6.2 Running total of cases per country
SELECT
    location,
    date,
    new_cases,
    SUM(new_cases) OVER (
        PARTITION BY location
        ORDER BY date
    )                               AS RunningTotalCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- 6.3 7-day rolling average of new cases per country
SELECT
    location,
    date,
    new_cases,
    AVG(CAST(new_cases AS FLOAT)) OVER (
        PARTITION BY location
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                               AS RollingAvg_7Day_Cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- 6.4 Rank countries by total deaths
SELECT
    location,
    MAX(CAST(total_deaths AS BIGINT))               AS TotalDeaths,
    RANK() OVER (
        ORDER BY MAX(CAST(total_deaths AS BIGINT)) DESC
    )                                               AS DeathRank
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathRank


-- 6.5 Rank countries by infection rate within each continent
SELECT
    continent,
    location,
    population,
    MAX(total_cases)                                AS TotalCases,
    MAX(total_cases) * 100.0 
        / NULLIF(population, 0)                     AS InfectionRate_Pct,
    RANK() OVER (
        PARTITION BY continent
        ORDER BY MAX(total_cases) * 100.0 
            / NULLIF(population, 0) DESC
    )                                               AS RankWithinContinent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY continent, RankWithinContinent


-- 6.6 CTE -- Rolling vaccination % of population
WITH VaccinationProgress AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
            PARTITION BY dea.location
            ORDER BY dea.date
        )                                           AS RollingVaccinations
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date    = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT
    *,
    RollingVaccinations * 100.0 
        / NULLIF(population, 0)                     AS RollingVaccinationRate_Pct
FROM VaccinationProgress
ORDER BY location, date


-- 6.7 TEMP TABLE version of rolling vaccination query
DROP TABLE IF EXISTS #VaccinationProgress

CREATE TABLE #VaccinationProgress (
    continent               NVARCHAR(255),
    location                NVARCHAR(255),
    date                    DATETIME,
    population              NUMERIC,
    new_vaccinations        NUMERIC,
    RollingVaccinations     NUMERIC
)

INSERT INTO #VaccinationProgress
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date    = vac.date
WHERE dea.continent IS NOT NULL

SELECT
    *,
    RollingVaccinations * 100.0 
        / NULLIF(population, 0)     AS RollingVaccinationRate_Pct
FROM #VaccinationProgress
ORDER BY location, date


-- ============================================================
-- CHAPTER 7: Views for Power BI
-- ============================================================

-- 7.1 View: Global death summary by country
-- Use in Power BI for world map / bar chart visuals
CREATE OR ALTER VIEW vw_CountryDeathSummary AS
SELECT
    location,
    population,
    MAX(total_cases)                                  AS TotalCases,
    MAX(CAST(total_deaths AS BIGINT))                 AS TotalDeaths,
    MAX(CAST(total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(total_cases), 0)                 AS DeathRate_Pct,
    MAX(CAST(total_deaths AS BIGINT)) * 100.0 
        / NULLIF(population, 0)                       AS DeathsPerPopulation_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population


-- 7.2 View: Infection rate by country
-- Use in Power BI for choropleth / top-N visuals
CREATE OR ALTER VIEW vw_CountryInfectionRate AS
SELECT
    location,
    population,
    MAX(total_cases)                              AS TotalCases,
    MAX(total_cases) * 100.0 
        / NULLIF(population, 0)                   AS InfectionRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population


-- 7.3 View: Daily global trend (cases + deaths)
-- Use in Power BI for line chart over time
CREATE OR ALTER VIEW vw_GlobalDailyTrend AS
SELECT
    date,
    SUM(new_cases)                  AS DailyNewCases,
    SUM(CAST(new_deaths AS BIGINT)) AS DailyNewDeaths,
    AVG(SUM(new_cases)) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                               AS RollingAvg_7Day_Cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date


-- 7.4 View: Rolling vaccination progress per country
-- Use in Power BI for vaccination tracker line chart
CREATE OR ALTER VIEW vw_RollingVaccinationProgress AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    )                                               AS RollingVaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) * 100.0 / NULLIF(dea.population, 0)           AS RollingVaccinationRate_Pct
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date    = vac.date
WHERE dea.continent IS NOT NULL


-- 7.5 View: Continent-level death summary
-- Use in Power BI for continent comparison bar chart
CREATE OR ALTER VIEW vw_ContinentDeathSummary AS
SELECT
    continent,
    SUM(CAST(new_deaths AS BIGINT))   AS TotalDeaths,
    SUM(new_cases)                    AS TotalCases,
    SUM(CAST(new_deaths AS BIGINT)) * 100.0 
        / NULLIF(SUM(new_cases), 0)   AS DeathRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent


-- 7.6 View: Vaccination vs death rate per country
-- Use in Power BI for scatter plot analysis
CREATE OR ALTER VIEW vw_VaccinationVsDeathRate AS
SELECT
    dea.location,
    dea.population,
    MAX(dea.total_cases)                                      AS TotalCases,
    MAX(CAST(dea.total_deaths AS BIGINT))                     AS TotalDeaths,
    MAX(CAST(dea.total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(dea.total_cases), 0)                     AS DeathRate_Pct,
    MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
        / NULLIF(dea.population, 0)                           AS VaccinationRate_Pct
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date    = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population


-- ============================================================
-- CHAPTER 8: Stored Procedures
-- ============================================================

-- 8.1 Get full COVID summary for any country
-- Usage: EXEC usp_CountrySummary 'India'
CREATE OR ALTER PROCEDURE usp_CountrySummary
    @CountryName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        dea.location,
        dea.population,
        MAX(dea.total_cases)                                      AS TotalCases,
        MAX(CAST(dea.total_deaths AS BIGINT))                     AS TotalDeaths,
        MAX(CAST(dea.total_deaths AS BIGINT)) * 100.0 
            / NULLIF(MAX(dea.total_cases), 0)                     AS DeathRate_Pct,
        MAX(dea.total_cases) * 100.0 
            / NULLIF(dea.population, 0)                           AS InfectionRate_Pct,
        MAX(CAST(vac.total_vaccinations AS BIGINT))               AS TotalVaccinations,
        MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
            / NULLIF(dea.population, 0)                           AS VaccinationRate_Pct
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date    = vac.date
    WHERE dea.location = @CountryName
    GROUP BY dea.location, dea.population
END


-- 8.2 Get daily trend for any country between two dates
-- Usage: EXEC usp_CountryDailyTrend 'India', '2021-01-01', '2021-12-31'
CREATE OR ALTER PROCEDURE usp_CountryDailyTrend
    @CountryName NVARCHAR(255),
    @StartDate   DATE,
    @EndDate     DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        location,
        date,
        new_cases,
        new_deaths,
        total_cases,
        total_deaths,
        AVG(CAST(new_cases AS FLOAT)) OVER (
            PARTITION BY location
            ORDER BY date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )                           AS RollingAvg_7Day_Cases
    FROM PortfolioProject..CovidDeaths
    WHERE location  = @CountryName
      AND date BETWEEN @StartDate AND @EndDate
    ORDER BY date
END


-- 8.3 Get top N countries by a chosen metric
-- Usage: EXEC usp_TopNCountries 'DeathRate', 10
CREATE OR ALTER PROCEDURE usp_TopNCountries
    @Metric NVARCHAR(50),   -- 'DeathRate' | 'InfectionRate' | 'TotalDeaths' | 'TotalCases'
    @TopN   INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Metric = 'DeathRate'
        SELECT TOP (@TopN)
            location,
            MAX(CAST(total_deaths AS BIGINT)) * 100.0 
                / NULLIF(MAX(total_cases), 0)   AS DeathRate_Pct
        FROM PortfolioProject..CovidDeaths
        WHERE continent IS NOT NULL
        GROUP BY location
        ORDER BY DeathRate_Pct DESC

    ELSE IF @Metric = 'InfectionRate'
        SELECT TOP (@TopN)
            location,
            MAX(total_cases) * 100.0 
                / NULLIF(population, 0)         AS InfectionRate_Pct
        FROM PortfolioProject..CovidDeaths
        WHERE continent IS NOT NULL
        GROUP BY location, population
        ORDER BY InfectionRate_Pct DESC

    ELSE IF @Metric = 'TotalDeaths'
        SELECT TOP (@TopN)
            location,
            MAX(CAST(total_deaths AS BIGINT))   AS TotalDeaths
        FROM PortfolioProject..CovidDeaths
        WHERE continent IS NOT NULL
        GROUP BY location
        ORDER BY TotalDeaths DESC

    ELSE IF @Metric = 'TotalCases'
        SELECT TOP (@TopN)
            location,
            MAX(total_cases)                    AS TotalCases
        FROM PortfolioProject..CovidDeaths
        WHERE continent IS NOT NULL
        GROUP BY location
        ORDER BY TotalCases DESC
END


-- 8.4 Get vaccination rollout for any country
-- Usage: EXEC usp_CountryVaccinationRollout 'India'
CREATE OR ALTER PROCEDURE usp_CountryVaccinationRollout
    @CountryName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        date,
        new_vaccinations,
        total_vaccinations,
        people_vaccinated,
        people_fully_vaccinated,
        total_vaccinations * 100.0 
            / NULLIF(
                (SELECT population 
                 FROM PortfolioProject..CovidDeaths 
                 WHERE location = @CountryName 
                   AND continent IS NOT NULL 
                 GROUP BY population), 
            0)                          AS VaccinationRate_Pct
    FROM PortfolioProject..CovidVaccinations
    WHERE location = @CountryName
    ORDER BY date
END


-- ============================================================
-- CHAPTER 9: Final Summary & KPI Queries
-- ============================================================

-- 9.1 Single-row global KPI snapshot
-- Total cases, deaths, global death rate, countries affected
SELECT
    COUNT(DISTINCT location)                              AS CountriesAffected,
    SUM(new_cases)                                        AS TotalCases_Global,
    SUM(CAST(new_deaths AS BIGINT))                       AS TotalDeaths_Global,
    SUM(CAST(new_deaths AS BIGINT)) * 100.0 
        / NULLIF(SUM(new_cases), 0)                       AS GlobalDeathRate_Pct,
    MIN(date)                                             AS PandemicStart,
    MAX(date)                                             AS DataEndDate,
    DATEDIFF(DAY, MIN(date), MAX(date))                   AS PandemicDays
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


-- 9.2 Vaccination KPI snapshot
SELECT
    COUNT(DISTINCT location)                                      AS CountriesWithVaccData,
    SUM(CAST(new_vaccinations AS BIGINT))                         AS TotalDosesAdministered,
    MAX(CAST(total_vaccinations AS BIGINT))                       AS PeakSingleCountryDoses,
    AVG(CAST(total_vaccinations AS FLOAT))                        AS AvgDosesPerCountry
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL


-- 9.3 Top 5 countries: highest infection rate
SELECT TOP 5
    location,
    population,
    MAX(total_cases)                              AS TotalCases,
    MAX(total_cases) * 100.0 
        / NULLIF(population, 0)                   AS InfectionRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate_Pct DESC


-- 9.4 Top 5 countries: highest death rate
SELECT TOP 5
    location,
    MAX(CAST(total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(total_cases), 0)             AS DeathRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathRate_Pct DESC


-- 9.5 Top 5 countries: highest vaccination rate
SELECT TOP 5
    vac.location,
    dea.population,
    MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
        / NULLIF(dea.population, 0)               AS VaccinationRate_Pct
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
    ON vac.location = vac.location
    AND vac.date    = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.location, dea.population
ORDER BY VaccinationRate_Pct DESC


-- 9.6 Continent-level KPI comparison
-- Cases, deaths, death rate side by side
SELECT
    continent,
    SUM(new_cases)                                AS TotalCases,
    SUM(CAST(new_deaths AS BIGINT))               AS TotalDeaths,
    SUM(CAST(new_deaths AS BIGINT)) * 100.0 
        / NULLIF(SUM(new_cases), 0)               AS DeathRate_Pct,
    COUNT(DISTINCT location)                      AS CountriesCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC


-- 9.7 India vs World: side-by-side KPI comparison
SELECT
    'India'                                               AS Scope,
    MAX(total_cases)                                      AS TotalCases,
    MAX(CAST(total_deaths AS BIGINT))                     AS TotalDeaths,
    MAX(CAST(total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(total_cases), 0)                     AS DeathRate_Pct,
    MAX(total_cases) * 100.0 
        / NULLIF(MAX(population), 0)                      AS InfectionRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'

UNION ALL

SELECT
    'Global'                                              AS Scope,
    SUM(new_cases)                                        AS TotalCases,
    SUM(CAST(new_deaths AS BIGINT))                       AS TotalDeaths,
    SUM(CAST(new_deaths AS BIGINT)) * 100.0 
        / NULLIF(SUM(new_cases), 0)                       AS DeathRate_Pct,
    NULL                                                  AS InfectionRate_Pct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


-- 9.8 Peak pandemic month globally
-- Which month had the most cases worldwide?
SELECT TOP 1
    YEAR(date)      AS PeakYear,
    MONTH(date)     AS PeakMonth,
    SUM(new_cases)  AS MonthlyCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY YEAR(date), MONTH(date)
ORDER BY MonthlyCases DESC


-- 9.9 DENSE_RANK: Countries ranked by vaccination rate (no gaps in rank)
SELECT
    vac.location,
    dea.population,
    MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
        / NULLIF(dea.population, 0)                           AS VaccinationRate_Pct,
    DENSE_RANK() OVER (
        ORDER BY MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
            / NULLIF(dea.population, 0) DESC
    )                                                         AS VaccinationRank
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
    ON vac.location = dea.location
    AND vac.date    = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.location, dea.population
ORDER BY VaccinationRank


-- 9.10 Final view: Master KPI table for Power BI dashboard
-- Single source of truth combining all key metrics per country
CREATE OR ALTER VIEW vw_MasterKPI AS
SELECT
    dea.location,
    dea.population,
    MAX(dea.total_cases)                                          AS TotalCases,
    MAX(CAST(dea.total_deaths AS BIGINT))                         AS TotalDeaths,
    MAX(CAST(dea.total_deaths AS BIGINT)) * 100.0 
        / NULLIF(MAX(dea.total_cases), 0)                         AS DeathRate_Pct,
    MAX(dea.total_cases) * 100.0 
        / NULLIF(dea.population, 0)                               AS InfectionRate_Pct,
    MAX(CAST(vac.total_vaccinations AS BIGINT))                   AS TotalVaccinations,
    MAX(CAST(vac.total_vaccinations AS BIGINT)) * 100.0 
        / NULLIF(dea.population, 0)                               AS VaccinationRate_Pct,
    AVG(dea.gdp_per_capita)                                       AS AvgGDP_PerCapita,
    AVG(dea.life_expectancy)                                      AS AvgLifeExpectancy,
    AVG(dea.stringency_index)                                     AS AvgStringencyIndex
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date    = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
