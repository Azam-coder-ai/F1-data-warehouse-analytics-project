/*
 ==================================================================
 Create Database and Schemas
 ==================================================================
 Script Purpose: 
 	This script creates a new database named 'DataWarehouse' after checking if it already exists.
 	if the database exists, it is droped and recreated. Additionally, the script sets up three schemas 
 	within the database: 'bronze', 'silver', 'gold'.
 
 WARNING:
 	Running this script will drop the entire 'DataWarehouse' if it exists.
 	All data in the database will be permanently deleted. Proceed with coution 
 	and ensure you have proper backups before running this script.
 */

--Create the 'DataWarehouse' database
CREATE database DataWarehouse;


--Create Schemas
CREATE SCHEMA IF NOT EXISTS bronze;
GO

CREATE SCHEMA IF NOT EXISTS silver;
GO

CREATE SCHEMA IF NOT EXISTS gold;
GO

