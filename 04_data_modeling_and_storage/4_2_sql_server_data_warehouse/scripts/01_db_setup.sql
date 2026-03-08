/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script initializes the 'DataWarehouse' database for the 
    synthetic bicycle sales dataset. It establishes the Medallion 
    Architecture by creating the 'bronze', 'silver', and 'gold' schemas.
*/

USE master;
GO

-- 1. Drop the database if it already exists to ensure a clean slate
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- 2. Create the new database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- 3. Create the Medallion Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO