/*
===============================================================================

DDl Scripts: Create Bronze Tables

===============================================================================
Script Pupose: 
	This script creates tables inn the 'bronze' schema, dropping existing tables
	if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables


Project Owner: AZAMBEK ANVAROV
===============================================================================
 */


CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.circuits;
create table bronze.circuits (
	circuitId int,
	circuitRef varchar(50),
	name varchar(50),
	location varchar(50),
	country varchar(50),
	lat float,
	lng  float,
	alt int,
	url varchar(50)
)

CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.constructor_results;
create table bronze.constructor_results(
	constructorResultsId int,
	raceId int,
	constructorID int,
	points int,
	status varchar(50)
)

CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.constructors;
create table bronze.constructors(
	onstructorId int,
	constructorRef varchar(50),
	name varchar(50),
	nationality varchar(50),
	url varchar(50)
) 


CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.constructor_standings;
create table bronze.constructor_standings(
	constructorStandingsId int,
	raceId int,
	constructorId int,
	points int,
	position int,
	positionText varchar(50),
	wins int
)


CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.drivers;
create table bronze.drivers(
	driverId int, 
	driverRef varchar(50), 
	number int,
	code varchar(50),
	forename varchar(50),
	surname varchar(50),
	dob date,
	nationality varchar(50),
	url varchar(50)
)


CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.driver_standing;
create table bronze.driver_standing(
	driverStandingsId int,
	raceId int,
	driverId int,
	points int,
	position int,
	positionText varchar(50),
	wins int
)


CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.lap_times;
create table  bronze.lap_times (
    race_id INT NOT NULL,
    driver_id INT NOT NULL,
    lap INT NOT NULL,
    position INT,
    time VARCHAR(20),
    milliseconds INT
) 


CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.pit_stops;
create table bronze.pit_stops(
	raceId int, 
	driverId int,
	stop int,
	lap int,
	time varchar(50),
	duration varchar(50),
	milliseconds int
)


CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.qualifying;
CREATE TABLE bronze.qualifying (
    qualify_id INT,
    race_id INT,
    driver_id INT,
    constructor_id INT,
    number INT,
    position INT,
    q1 VARCHAR(20),
    q2 VARCHAR(20),
    q3 VARCHAR(20)
   )
   
   
CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.races;
   CREATE TABLE bronze.races (
    race_id INT,
    year INT,
    round INT,
    circuit_id INT,
    name VARCHAR(255),
    date DATE,
    time TIME,
    url VARCHAR(512),
    fp1_date VARCHAR(20),
    fp1_time VARCHAR(20),
    fp2_date VARCHAR(20),
    fp2_time VARCHAR(20),
    fp3_date VARCHAR(20),
    fp3_time VARCHAR(20),
    quali_date VARCHAR(20),
    quali_time VARCHAR(20),
    sprint_date VARCHAR(20),
    sprint_time VARCHAR(20)
   )

   
CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.results;
   CREATE TABLE bronze.results (
    result_id INT,
    race_id INT,
    driver_id INT,
    constructor_id INT,
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
    status_id INT
    ) 
    
    
    
CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.seasons;
    CREATE TABLE bronze.seasons (
    year INT,
    url VARCHAR(50)
    )
    
    
CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.sprint_results;
    CREATE TABLE bronze.sprint_results (
    result_id INT,
    race_id INT,
    driver_id INT,
    constructor_id INT,
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
    status_id INT
    )
    
    
CREATE SCHEMA IF NOT EXISTS bronze;
	DROP TABLE IF EXISTS bronze.status;
    CREATE TABLE bronze.status (
    status_id INT,
    status VARCHAR(50)
    )
