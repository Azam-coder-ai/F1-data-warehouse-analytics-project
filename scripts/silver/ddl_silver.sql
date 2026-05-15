/*
===============================================================================
DDL Scripts: Create Silver Tables
===============================================================================
Script Purpose: 
	This script creates tables in the 'silver' schema, dropping existing tables
	if they already exist. 
  Run this script to re-define the DDL structure of 'bronze' Tables

Project Owner: AZAMBEK ANVAROV

===============================================================================
*/

call silver.load_silver()
CREATE SCHEMA IF NOT EXISTS silver;

-- ==========================================
-- STAGE 1: DIMENSIONS (PARENT TABLES)
-- ==========================================

-- 1. Seasons
DROP TABLE IF EXISTS silver.seasons CASCADE;
CREATE TABLE silver.seasons (
    year INT PRIMARY KEY,
    url VARCHAR(250), 
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 2. Status
DROP TABLE IF EXISTS silver.status CASCADE;
CREATE TABLE silver.status (
    status_id INT PRIMARY KEY,
    status VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 3. Circuits
DROP TABLE IF EXISTS silver.circuits CASCADE;
CREATE TABLE silver.circuits (
    circuitId INT PRIMARY KEY,
    circuitRef VARCHAR(50),
    name VARCHAR(50),
    location VARCHAR(50),
    country VARCHAR(50),
    lat FLOAT,
    lng FLOAT,
    alt INT,
    url VARCHAR(250), 
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 4. Constructors
DROP TABLE IF EXISTS silver.constructors CASCADE;
CREATE TABLE silver.constructors (
    onstructorId INT PRIMARY KEY,
    constructorRef VARCHAR(50),
    name VARCHAR(50),
    nationality VARCHAR(50),
    url VARCHAR(250), 
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 5. Drivers
DROP TABLE IF EXISTS silver.drivers CASCADE;
CREATE TABLE silver.drivers (
    driverId INT PRIMARY KEY,
    driverRef VARCHAR(50),
    number INT,
    code VARCHAR(50),
    forename VARCHAR(50),
    surname VARCHAR(50),
    dob DATE,
    nationality VARCHAR(50),
    url VARCHAR(250), 
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- ==========================================
-- STAGE 2: INTERMEDIATE TABLES
-- ==========================================

-- 6. Races
DROP TABLE IF EXISTS silver.races CASCADE;
CREATE TABLE silver.races (
    race_id INT PRIMARY KEY,
    year INT REFERENCES silver.seasons(year),
    round INT,
    circuit_id INT REFERENCES silver.circuits(circuitId),
    name VARCHAR(255),
    date DATE,
    time TIME,
    url VARCHAR(250), -- Updated size
    fp1_date VARCHAR(20),
    fp1_time VARCHAR(20),
    fp2_date VARCHAR(20),
    fp2_time VARCHAR(20),
    fp3_date VARCHAR(20),
    fp3_time VARCHAR(20),
    quali_date VARCHAR(20),
    quali_time VARCHAR(20),
    sprint_date VARCHAR(20),
    sprint_time VARCHAR(20),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- ==========================================
-- STAGE 3: FACTS (CHILD TABLES)
-- ==========================================

-- 7. Constructor Results
DROP TABLE IF EXISTS silver.constructor_results CASCADE;
CREATE TABLE silver.constructor_results (
    constructorResultsId INT PRIMARY KEY,
    raceId INT REFERENCES silver.races(race_id),
    constructorID INT REFERENCES silver.constructors(onstructorId),
    points INT,
    status VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 8. Constructor Standings
DROP TABLE IF EXISTS silver.constructor_standings CASCADE;
CREATE TABLE silver.constructor_standings (
    constructorStandingsId INT PRIMARY KEY,
    raceId INT REFERENCES silver.races(race_id),
    constructorId INT REFERENCES silver.constructors(onstructorId),
    points INT,
    position INT,
    positionText VARCHAR(50),
    wins INT,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 9. Driver Standing
DROP TABLE IF EXISTS silver.driver_standing CASCADE;
CREATE TABLE silver.driver_standing (
    driverStandingsId INT PRIMARY KEY,
    raceId INT REFERENCES silver.races(race_id),
    driverId INT REFERENCES silver.drivers(driverId),
    points INT,
    position INT,
    positionText VARCHAR(50),
    wins INT,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 10. Lap Times
DROP TABLE IF EXISTS silver.lap_times CASCADE;
CREATE TABLE silver.lap_times (
    race_id INT REFERENCES silver.races(race_id),
    driver_id INT REFERENCES silver.drivers(driverId),
    lap INT NOT NULL,
    position INT,
    time VARCHAR(20),
    milliseconds INT,
    PRIMARY KEY (race_id, driver_id, lap),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 11. Pit Stops
DROP TABLE IF EXISTS silver.pit_stops CASCADE;
CREATE TABLE silver.pit_stops (
    raceId INT REFERENCES silver.races(race_id),
    driverId INT REFERENCES silver.drivers(driverId),
    stop INT NOT NULL,
    lap INT,
    time VARCHAR(50),
    duration VARCHAR(50),
    milliseconds INT,
    PRIMARY KEY (raceId, driverId, stop),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 12. Qualifying
DROP TABLE IF EXISTS silver.qualifying CASCADE;
CREATE TABLE silver.qualifying (
    qualify_id INT PRIMARY KEY,
    race_id INT REFERENCES silver.races(race_id),
    driver_id INT REFERENCES silver.drivers(driverId),
    constructor_id INT REFERENCES silver.constructors(onstructorId),
    number INT,
    position INT,
    q1 VARCHAR(20),
    q2 VARCHAR(20),
    q3 VARCHAR(20),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 13. Results
DROP TABLE IF EXISTS silver.results CASCADE;
CREATE TABLE silver.results (
    result_id INT PRIMARY KEY,
    race_id INT REFERENCES silver.races(race_id),
    driver_id INT REFERENCES silver.drivers(driverId),
    constructor_id INT REFERENCES silver.constructors(onstructorId),
    number INT,
    grid INT,
    position VARCHAR(10), 
    position_text VARCHAR(10),
    position_order INT,
    points FLOAT,
    laps INT,
    time VARCHAR(50),
    milliseconds VARCHAR(20), 
    fastest_lap VARCHAR(10),
    rank VARCHAR(10),
    fastest_lap_time VARCHAR(20),
    fastest_lap_speed VARCHAR(20),
    status_id INT REFERENCES silver.status(status_id),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);

-- 14. Sprint Results
DROP TABLE IF EXISTS silver.sprint_results CASCADE;
CREATE TABLE silver.sprint_results (
    result_id INT PRIMARY KEY,
    race_id INT REFERENCES silver.races(race_id),
    driver_id INT REFERENCES silver.drivers(driverId),
    constructor_id INT REFERENCES silver.constructors(onstructorId),
    number INT,
    grid INT,
    position INT,
    position_text VARCHAR(10),
    position_order INT,
    points FLOAT,
    laps INT,
    time VARCHAR(50),
    milliseconds INT,
    fastest_lap INT,
    fastest_lap_time VARCHAR(20),
    status_id INT REFERENCES silver.status(status_id),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dwh_source_system VARCHAR(50) DEFAULT 'Bronze F1 CSV'
);
