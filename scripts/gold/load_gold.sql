-- ============================================================================
/* 
  Script Purpose:    
      This script handles the final "Gold" layer transformations within a Medallion 
      Data Architecture. It converts normalized Silver tables into analytical Fact 
      and Dimension structures (Star Schema) and builds pre-aggregated Materialized 
      Views. This eliminates expensive real-time calculation overhead on downstream 
      BI platforms like Tableau or Power BI.

 ============================================================================
    Project Owner: AZAMBEK ANVAROV
    

============================================================================
*/
-- 1. DIMENSION TABLES (Star Schema Dimensions)
-- ============================================================================

-- A. dim_drivers (Driver Profiles Dimension)
DROP TABLE IF EXISTS gold.dim_drivers CASCADE;
CREATE TABLE gold.dim_drivers AS
SELECT 
    driver_id,
    driver_ref,
    number AS driver_number,
    code AS driver_code,
    CONCAT(forename, ' ', surname) AS driver_name,
    dob AS date_of_birth,
    nationality AS driver_nationality
FROM silver.drivers;

ALTER TABLE gold.dim_drivers ADD PRIMARY KEY (driver_id);


-- B. dim_constructors (Team/Constructor Dimension)
DROP TABLE IF EXISTS gold.dim_constructors CASCADE;
CREATE TABLE gold.dim_constructors AS
SELECT 
    constructor_id,
    constructor_ref,
    name AS constructor_name,
    nationality AS constructor_nationality
FROM silver.constructors;

ALTER TABLE gold.dim_constructors ADD PRIMARY KEY (constructor_id);


-- C. dim_races (Denormalized Race & Circuit Dimension)
DROP TABLE IF EXISTS gold.dim_races CASCADE;
CREATE TABLE gold.dim_races AS
SELECT 
    r.race_id,
    r.year AS race_year,
    r.round AS race_round,
    r.name AS race_name,
    r.date AS race_date,
    c.name AS circuit_name,
    c.location AS circuit_location,
    c.country AS circuit_country
FROM silver.races r
JOIN silver.circuits c ON r.circuit_id = c.circuit_id;

ALTER TABLE gold.dim_races ADD PRIMARY KEY (race_id);


-- ============================================================================
-- 2. FACT TABLES (Star Schema Facts)
-- ============================================================================

-- A. fact_race_results (Race Performance & Points Fact)
DROP TABLE IF EXISTS gold.fact_race_results CASCADE;
CREATE TABLE gold.fact_race_results AS
SELECT 
    res.result_id,
    res.race_id,
    res.driver_id,
    res.constructor_id,
    res.grid AS grid_start_position,
    res.position_order AS final_position,
    res.points AS points_earned,
    res.laps AS laps_completed,
    res.time AS total_race_time,
    res.fastest_lap AS fastest_lap_number,
    res.fastest_lap_time,
    res.fastest_lap_speed,
    s.status AS race_status
FROM silver.results res
JOIN silver.status s ON res.status_id = s.status_id;

ALTER TABLE gold.fact_race_results ADD PRIMARY KEY (result_id);


-- B. fact_pit_stops (Pit Stop Efficiency Fact)
DROP TABLE IF EXISTS gold.fact_pit_stops CASCADE;
CREATE TABLE gold.fact_pit_stops AS
SELECT 
    race_id,
    driver_id,
    stop AS pit_stop_number,
    lap AS pit_stop_lap,
    time AS pit_stop_time,
    duration::NUMERIC AS pit_stop_duration_seconds,
    milliseconds AS pit_stop_milliseconds
FROM silver.pit_stops;


-- ============================================================================
-- 3. DATA INTEGRITY & PERFORMANCE TUNING (Indexing & Constraints)
-- ============================================================================

-- Enforce Foreign Key Constraints for automatic BI relationship detection
ALTER TABLE gold.fact_race_results ADD CONSTRAINT fk_race FOREIGN KEY (race_id) REFERENCES gold.dim_races(race_id);
ALTER TABLE gold.fact_race_results ADD CONSTRAINT fk_driver FOREIGN KEY (driver_id) REFERENCES gold.dim_drivers(driver_id);
ALTER TABLE gold.fact_race_results ADD CONSTRAINT fk_constructor FOREIGN KEY (constructor_id) REFERENCES gold.dim_constructors(constructor_id);

-- Create B-Tree Indexes to maximize join speeds for interactive dashboards
CREATE INDEX idx_fact_results_race ON gold.fact_race_results(race_id);
CREATE INDEX idx_fact_results_driver ON gold.fact_race_results(driver_id);
CREATE INDEX idx_fact_pit_race_driver ON gold.fact_pit_stops(race_id, driver_id);


-- ============================================================================
-- 4. ANALYTICAL DATA MARTS (Pre-aggregated Materialized Views for Dashboarding)
-- ============================================================================

-- Mart 1: Driver Championship Standings (Pre-calculated points and historical ranks)
DROP MATERIALIZED VIEW IF EXISTS gold.mv_dashboard_driver_standings;
CREATE MATERIALIZED VIEW gold.mv_dashboard_driver_standings AS
SELECT 
    r.race_year,
    d.driver_name,
    c.constructor_name,
    SUM(f.points_earned) AS total_points,
    COUNT(CASE WHEN f.final_position = 1 THEN 1 END) AS total_wins,
    COUNT(CASE WHEN f.final_position <= 3 THEN 1 END) AS total_podiums,
    RANK() OVER (PARTITION BY r.race_year ORDER BY SUM(f.points_earned) DESC) AS championship_rank
FROM gold.fact_race_results f
JOIN gold.dim_races r ON f.race_id = r.race_id
JOIN gold.dim_drivers d ON f.driver_id = d.driver_id
JOIN gold.dim_constructors c ON f.constructor_id = c.constructor_id
GROUP BY r.race_year, d.driver_name, c.constructor_name;


-- Mart 2: Constructor Pit Stop Performance (Team operational speed analytics)
DROP MATERIALIZED VIEW IF EXISTS gold.mv_dashboard_pit_stops;
CREATE MATERIALIZED VIEW gold.mv_dashboard_pit_stops AS
SELECT 
    r.race_year,
    c.constructor_name,
    ROUND(AVG(p.pit_stop_duration_seconds), 2) AS avg_pit_stop_seconds,
    MIN(p.pit_stop_duration_seconds) AS fastest_pit_stop_seconds,
    COUNT(p.pit_stop_number) AS total_pit_stops
FROM gold.fact_pit_stops p
JOIN gold.dim_races r ON p.race_id = r.race_id
JOIN gold.fact_race_results f ON p.race_id = f.race_id AND p.driver_id = f.driver_id
JOIN gold.dim_constructors c ON f.constructor_id = c.constructor_id
GROUP BY r.race_year, c.constructor_name;

-- Note: Execute the following to refresh the dashboard data cache on data ingestion pipelines:
-- REFRESH MATERIALIZED VIEW gold.mv_dashboard_driver_standings;
-- REFRESH MATERIALIZED VIEW gold.mv_dashboard_pit_stops;
