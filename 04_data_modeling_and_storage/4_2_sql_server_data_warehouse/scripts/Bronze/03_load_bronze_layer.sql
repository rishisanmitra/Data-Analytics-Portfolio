/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    
    * Updated with FORMAT = 'CSV' and Hexadecimal ROWTERMINATOR ('0x0A') 
      to securely handle synthetic data line breaks.

NOTE TO USER: 
    Replace 'C:\path\to\your\project\' with the actual absolute path to your 
    local 'data\raw\' directory before executing.
===============================================================================
*/

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    BEGIN TRY
        PRINT 'Loading Bronze Layer...';

        -- 1. Load CRM Customer Info
        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\path\to\your\project\data\raw\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '0x0A',
            FORMAT = 'CSV',
            TABLOCK
        );

        -- 2. Load CRM Product Info
        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\path\to\your\project\data\raw\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '0x0A',
            FORMAT = 'CSV',
            TABLOCK
        );

        -- 3. Load CRM Sales Details
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\path\to\your\project\data\raw\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '0x0A',
            FORMAT = 'CSV',
            TABLOCK
        );

        -- 4. Load ERP Location (A101)
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\path\to\your\project\data\raw\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '0x0A',
            FORMAT = 'CSV',
            TABLOCK
        );

        -- 5. Load ERP Customer Demographics (AZ12)
        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\path\to\your\project\data\raw\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '0x0A',
            FORMAT = 'CSV',
            TABLOCK
        );

        -- 6. Load ERP Category Hierarchy (G1V2)
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\path\to\your\project\data\raw\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '0x0A',
            FORMAT = 'CSV',
            TABLOCK
        );

        PRINT 'Bronze Layer Loaded Successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-- To execute the stored procedure, run:
-- EXEC bronze.load_bronze;