/*
=====================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=====================================================================================
Script Purpose: 
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
  Actions Performed:
      - Truncate Silver Tables:
      - Inserts transformed and cleansed data from Bronze into Silver tables.

  Parameters: 
      None.
      This stored procedure does not accept any parameters or return any values.

  Usage example:
    CALL call silver.load_silver()

    Project Owner: AZAMBEK ANVAROV

=====================================================================================
*/

CREATE OR REPLACE PROCEDURE   call silver.load_silver()
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
	RAISE NOTICE 'STARTING SILVER LAYER AUTOMATED PIPELINE (TRUNCATE + INSERT)';
	RAISE NOTICE '==========================================================';

	-- ==========================================================
	-- STAGE 1: INDEPENDENT DIMENSIONS (PARENT TABLES)
	-- ==========================================================
	
	-- 1. Seasons
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.seasons CASCADE;
		INSERT INTO silver.seasons (year, url)
		SELECT year, NULLIF(TRIM(url), '') FROM bronze.seasons
		ON CONFLICT (year) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.seasons processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.seasons: %', SQLERRM; END;

	-- 2. Status
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.status CASCADE;
		INSERT INTO silver.status (status_id, status)
		SELECT status_id, INITCAP(TRIM(status)) FROM bronze.status
		ON CONFLICT (status_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.status processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.status: %', SQLERRM; END;

	-- 3. Circuits
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.circuits CASCADE;
		INSERT INTO silver.circuits (circuit_id, circuit_ref, name, location, country, lat, lng, alt, url)
		SELECT circuitId, INITCAP(REPLACE(TRIM(circuitRef), '_', ' ')), INITCAP(REPLACE(TRIM(name), '_', ' ')), 
		       INITCAP(TRIM(location)), INITCAP(TRIM(country)), lat, lng, alt, NULLIF(TRIM(url), '')
		FROM bronze.circuits
		ON CONFLICT (circuit_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.circuits processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.circuits: %', SQLERRM; END;

	-- 4. Constructors
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.constructors CASCADE;
		INSERT INTO silver.constructors (constructor_id, constructor_ref, name, nationality, url)
		SELECT constructorid, INITCAP(REPLACE(TRIM(constructorRef), '_', ' ')), INITCAP(TRIM(name)), INITCAP(TRIM(nationality)), NULLIF(TRIM(url), '')
		FROM bronze.constructors
		ON CONFLICT (constructor_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.constructors processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.constructors: %', SQLERRM; END;

	-- 5. Drivers
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.drivers CASCADE;
		INSERT INTO silver.drivers (driver_id, driver_ref, number, code, forename, surname, full_name, dob, nationality, url)
		SELECT driverId, INITCAP(REPLACE(TRIM(driverRef), '_', ' ')), number, UPPER(NULLIF(TRIM(code), '')), 
		       INITCAP(TRIM(forename)), INITCAP(TRIM(surname)), INITCAP(TRIM(forename)) || ' ' || INITCAP(TRIM(surname)), dob, INITCAP(TRIM(nationality)), NULLIF(TRIM(url), '')
		FROM bronze.drivers
		ON CONFLICT (driver_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.drivers processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.drivers: %', SQLERRM; END;

	-- ==========================================================
	-- STAGE 2: INTERMEDIATE BRIDGE TABLES
	-- ==========================================================
	
	-- 6. Races
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.races CASCADE;
		INSERT INTO silver.races (race_id, year, round, circuit_id, name, date, time, url, fp1_date, fp1_time, fp2_date, fp2_time, fp3_date, fp3_time, quali_date, quali_time, sprint_date, sprint_time)
		SELECT 
		    race_id, year, round, circuit_id, INITCAP(TRIM(name)), date, time, NULLIF(TRIM(url), ''),
		    NULLIF(TRIM(fp1_date), '')::DATE, NULLIF(TRIM(fp1_time), '')::TIME,
		    NULLIF(TRIM(fp2_date), '')::DATE, NULLIF(TRIM(fp2_time), '')::TIME,
		    NULLIF(TRIM(fp3_date), '')::DATE, NULLIF(TRIM(fp3_time), '')::TIME,
		    NULLIF(TRIM(quali_date), '')::DATE, NULLIF(TRIM(quali_time), '')::TIME,
		    NULLIF(TRIM(sprint_date), '')::DATE, NULLIF(TRIM(sprint_time), '')::TIME
		FROM bronze.races
		ON CONFLICT (race_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.races processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.races: %', SQLERRM; END;

	-- ==========================================================
	-- STAGE 3: DEPENDENT FACTS (CHILD TABLES)
	-- ==========================================================
	
	-- 7. Constructor Results
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.constructor_results CASCADE;
		INSERT INTO silver.constructor_results (constructor_results_id, race_id, constructor_id, points, status)
		SELECT constructorresultsid, raceid, constructorid, points, NULLIF(TRIM(status), '') 
		FROM bronze.constructor_results
		ON CONFLICT (constructor_results_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.constructor_results processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.constructor_results: %', SQLERRM; END;

	-- 8. Constructor Standings
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.constructor_standings CASCADE;
		INSERT INTO silver.constructor_standings (constructor_standings_id, race_id, constructor_id, points, position, position_text, wins)
		SELECT constructorstandingsid, raceid, constructorid, points, position, UPPER(NULLIF(TRIM(positiontext), '')), wins 
		FROM bronze.constructor_standings
		ON CONFLICT (constructor_standings_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.constructor_standings processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.constructor_standings: %', SQLERRM; END;

	-- 9. Driver Standing
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.driver_standing CASCADE;
		INSERT INTO silver.driver_standing (driver_standings_id, race_id, driver_id, points, position, position_text, wins)
		SELECT driverstandingsid, raceid, driverid, points, position, UPPER(NULLIF(TRIM(positiontext), '')), wins 
		FROM bronze.driver_standing
		ON CONFLICT (driver_standings_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.driver_standing processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.driver_standing: %', SQLERRM; END;

	-- 10. Lap Times
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.lap_times CASCADE;
		INSERT INTO silver.lap_times (race_id, driver_id, lap, position, time, milliseconds)
		SELECT race_id, driver_id, lap, position, NULLIF(TRIM(time), ''), milliseconds 
		FROM bronze.lap_times
		ON CONFLICT (race_id, driver_id, lap) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.lap_times processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.lap_times: %', SQLERRM; END;

	-- 11. Pit Stops
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.pit_stops CASCADE;
		INSERT INTO silver.pit_stops (race_id, driver_id, stop, lap, time, duration, milliseconds)
		SELECT raceId, driverId, stop, lap, NULLIF(TRIM(time), ''), NULLIF(TRIM(duration), ''), milliseconds 
		FROM bronze.pit_stops
		ON CONFLICT (race_id, driver_id, stop) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.pit_stops processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.pit_stops: %', SQLERRM; END;

	-- 12. Qualifying (FIXED: Changed source select name to constructor_id)
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.qualifying CASCADE;
		INSERT INTO silver.qualifying (qualify_id, race_id, driver_id, constructor_id, number, position, q1, q2, q3)
		SELECT qualify_id, race_id, driver_id, constructor_id, number, position, 
		       CASE WHEN TRIM(q1) = '\N' THEN NULL ELSE NULLIF(TRIM(q1), '') END, 
		       CASE WHEN TRIM(q2) = '\N' THEN NULL ELSE NULLIF(TRIM(q2), '') END, 
		       CASE WHEN TRIM(q3) = '\N' THEN NULL ELSE NULLIF(TRIM(q3), '') END 
		FROM bronze.qualifying
		ON CONFLICT (qualify_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.qualifying processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.qualifying: %', SQLERRM; END;

	-- 13. Results (FIXED: Changed source select name to constructor_id)
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.results CASCADE;
		INSERT INTO silver.results (result_id, race_id, driver_id, constructor_id, number, grid, position, position_text, position_order, points, laps, time, milliseconds, fastest_lap, rank, fastest_lap_time, fastest_lap_speed, status_id)
		SELECT result_id, race_id, driver_id, constructor_id, number, grid, 
		       CASE WHEN TRIM(position) = '\N' THEN NULL ELSE NULLIF(TRIM(position), '') END, 
		       UPPER(NULLIF(TRIM(position_text), '')), position_order, points, laps, 
		       CASE WHEN TRIM(time) = '\N' THEN NULL ELSE NULLIF(TRIM(time), '') END, 
		       CASE WHEN TRIM(milliseconds) = '\N' THEN NULL ELSE NULLIF(TRIM(milliseconds), '') END, 
		       CASE WHEN TRIM(fastest_lap) = '\N' THEN NULL ELSE NULLIF(TRIM(fastest_lap), '') END, 
		       CASE WHEN TRIM(rank) = '\N' THEN NULL ELSE NULLIF(TRIM(rank), '') END, 
		       CASE WHEN TRIM(fastest_lap_time) = '\N' THEN NULL ELSE NULLIF(TRIM(fastest_lap_time), '') END, 
		       CASE WHEN TRIM(fastest_lap_speed) = '\N' THEN NULL ELSE NULLIF(TRIM(fastest_lap_speed), '') END, 
		       status_id 
		FROM bronze.results
		ON CONFLICT (result_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.results processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.results: %', SQLERRM; END;

	-- 14. Sprint Results (FIXED: Changed source select name to constructor_id)
	BEGIN 
		start_time := clock_timestamp();
		TRUNCATE TABLE silver.sprint_results CASCADE;
		INSERT INTO silver.sprint_results (result_id, race_id, driver_id, constructor_id, number, grid, position, position_text, position_order, points, laps, time, milliseconds, fastest_lap, fastest_lap_time, status_id)
		SELECT result_id, race_id, driver_id, constructor_id, number, grid, position, UPPER(NULLIF(TRIM(position_text), '')), position_order, points, laps, 
		       CASE WHEN TRIM(time) = '\N' THEN NULL ELSE NULLIF(TRIM(time), '') END, 
		       milliseconds, fastest_lap, 
		       CASE WHEN TRIM(fastest_lap_time) = '\N' THEN NULL ELSE NULLIF(TRIM(fastest_lap_time), '') END, 
		       status_id 
		FROM bronze.sprint_results
		ON CONFLICT (result_id) DO NOTHING;
		end_time := clock_timestamp();
		RAISE NOTICE '--> [SUCCESS] silver.sprint_results processed in %', (end_time - start_time);
		RAISE NOTICE '---------------';
	EXCEPTION WHEN OTHERS THEN RAISE NOTICE '--> [ERROR] silver.sprint_results: %', SQLERRM; END;

	total_end_time := clock_timestamp();
	RAISE NOTICE '==========================================================';
	RAISE NOTICE 'SILVER LAYER REFRESHED. Total Execution Duration: %', (total_end_time - total_start_time);
	RAISE NOTICE '==========================================================';
END $$;
