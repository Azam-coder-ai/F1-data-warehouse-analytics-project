/*
 =========================================================================================
 
 Stored Procedure: Load Bronze Layer (Source -> Bronze)
 
 =========================================================================================
 
 Script Purpose:
 	This stored procedure loads data into the 'bronze' schema from external CSV files.
 	It performs the following actions:
 	- Truncate the bronze tables from tables before loading data.
 	- Uses the 'COPY' command to load data from csv Files to bronze tables.
 	
 Parameters;
 	None.
 	This stored procedure does not accept any parameters or return any values.
 	
 Usage Examples":
 	CALL bronze.load_bronze();
=========================================================================================
 */


CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql 
AS $$ 
DECLARE 
	start_time timestamp;
	end_time timestamp;
	total_start_time timestamp;
	total_end_time timestamp;
BEGIN
	total_start_time := clock_timestamp();

	RAISE NOTICE '==========================================================';
	RAISE NOTICE 'Loading Bronze Layer';
	RAISE NOTICE '==========================================================';

	RAISE NOTICE '----------------------------------------------------------';
	RAISE NOTICE 'Loading Tables';
	RAISE NOTICE '----------------------------------------------------------';
	
	-- 1. Circuits
	BEGIN 
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.circuits';
		TRUNCATE TABLE bronze.circuits;
		RAISE NOTICE '--> Inserting Data Into: bronze.circuits';
		COPY bronze.circuits (circuitid, circuitref, name, location, country, lat, lng, alt, url)
		FROM '/opt/formula1_project/formula1_data/circuits.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.circuits loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.circuits. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;

	-- 2. Constructor Results
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.constructor_results';
		TRUNCATE TABLE bronze.constructor_results;
		RAISE NOTICE '--> Inserting Data Into: bronze.constructor_results';
		COPY bronze.constructor_results(constructorresultsid, raceid, constructorid, points, status)
		FROM '/opt/formula1_project/formula1_data/constructor_results.csv'
		WITH (format csv, header true, delimiter ',', null '\N'); 
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.constructor_results loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.constructor_results. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 3. Constructor Standings
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.constructor_standings';
		TRUNCATE TABLE bronze.constructor_standings;
		RAISE NOTICE '--> Inserting Data Into: bronze.constructor_standings';
		COPY bronze.constructor_standings(constructorstandingsid, raceid, constructorid, points, position, positiontext, wins)
		FROM '/opt/formula1_project/formula1_data/constructor_standings.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.constructor_standings loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.constructor_standings. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;	
	
	-- 4. Constructors
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.constructors';
		TRUNCATE TABLE bronze.constructors;
		RAISE NOTICE '--> Inserting Data Into: bronze.constructors';
		COPY bronze.constructors(constructorid, constructorref, name, nationality, url)
		FROM '/opt/formula1_project/formula1_data/constructors.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.constructors loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.constructors. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 5. Drivers
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.drivers';
		TRUNCATE TABLE bronze.drivers;
		RAISE NOTICE '--> Inserting Data Into: bronze.drivers';
		COPY bronze.drivers(driverid, driverref, number, code, forename, surname, dob, nationality, url)
		FROM '/opt/formula1_project/formula1_data/drivers.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.drivers loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.drivers. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 6. Driver Standings
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.driver_standing';
		TRUNCATE TABLE bronze.driver_standing;
		RAISE NOTICE '--> Inserting Data Into: bronze.driver_standing';
		COPY bronze.driver_standing(driverstandingsid, raceid, driverid, points, position, positiontext, wins)
		FROM '/opt/formula1_project/formula1_data/driver_standings.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.driver_standing loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.driver_standing. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 7. Lap Times
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.lap_times';
		TRUNCATE TABLE bronze.lap_times;
		RAISE NOTICE '--> Inserting Data Into: bronze.lap_times';
		COPY bronze.lap_times(race_id, driver_id, lap, position, time, milliseconds)
		FROM '/opt/formula1_project/formula1_data/lap_times.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.lap_times loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.lap_times. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 8. Pit Stops
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.pit_stops';
		TRUNCATE TABLE bronze.pit_stops;
		RAISE NOTICE '--> Inserting Data Into: bronze.pit_stops';
		COPY bronze.pit_stops(raceid, driverid, stop, lap, time, duration, milliseconds)
		FROM '/opt/formula1_project/formula1_data/pit_stops.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.pit_stops loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.pit_stops. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 9. Qualifying
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.qualifying';
		TRUNCATE TABLE bronze.qualifying;
		RAISE NOTICE '--> Inserting Data Into: bronze.qualifying';
		COPY bronze.qualifying(qualify_id, race_id, driver_id, constructor_id, number, position, q1, q2, q3)
		FROM '/opt/formula1_project/formula1_data/qualifying.csv' 
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.qualifying loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.qualifying. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 10. Races
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.races';
		TRUNCATE TABLE bronze.races;
		RAISE NOTICE '--> Inserting Data Into: bronze.races';
		COPY bronze.races(race_id, year, round, circuit_id, name, date, time, url, fp1_date, fp1_time, fp2_date, fp2_time, fp3_date, fp3_time, quali_date, quali_time, sprint_date, sprint_time)
		FROM '/opt/formula1_project/formula1_data/races.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.races loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.races. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	 
	-- 11. Results
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.results';
		TRUNCATE TABLE bronze.results;
		RAISE NOTICE '--> Inserting Data Into: bronze.results';
		COPY bronze.results(result_id, race_id, driver_id, constructor_id, number, grid, position, position_text, position_order, points, laps, time, milliseconds, fastest_lap, rank, fastest_lap_time, fastest_lap_speed, status_id)
		FROM '/opt/formula1_project/formula1_data/results.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.results loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.results. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 12. Seasons
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.seasons';
		TRUNCATE TABLE bronze.seasons;
		RAISE NOTICE '--> Inserting Data Into: bronze.seasons';
		COPY bronze.seasons(year, url)
		FROM '/opt/formula1_project/formula1_data/seasons.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.seasons loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.seasons. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 13. Sprint Results
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.sprint_results';
		TRUNCATE TABLE bronze.sprint_results;
		RAISE NOTICE '--> Inserting Data Into: bronze.sprint_results';
		COPY bronze.sprint_results(result_id, race_id, driver_id, constructor_id, number, grid, position, position_text, position_order, points, laps, time, milliseconds, fastest_lap, fastest_lap_time, status_id)
		FROM '/opt/formula1_project/formula1_data/sprint_results.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.sprint_results loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.sprint_results. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;
	
	-- 14. Status
	BEGIN
		start_time := clock_timestamp();
		RAISE NOTICE '--> Truncating Table: bronze.status';
		TRUNCATE TABLE bronze.status;
		RAISE NOTICE '--> Inserting Data Into: bronze.status';
		COPY bronze.status(status_id, status)
		FROM '/opt/formula1_project/formula1_data/status.csv'
		WITH (format csv, header true, delimiter ',', null '\N');
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] bronze.status loaded in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE '--> [ERROR] Failed to load bronze.status. Reason: %', SQLERRM;
		RAISE NOTICE '---------------';
	END;

	total_end_time := clock_timestamp();
	RAISE NOTICE '----------------------------------------------------------';
	RAISE NOTICE 'All Tables Processed. Total Duration: %', (total_end_time - total_start_time);
	RAISE NOTICE '----------------------------------------------------------';
END $$;
