USE DataWarehouse;
GO

-- 1. Retrieve a list of all tables in the database
-- This helps verify that your Bronze, Silver, and Gold layers are all present.
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- 2. Retrieve all columns for the Customer Dimension
-- Use this to verify data types and lengths for your gold-layer views.
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
  AND TABLE_SCHEMA = 'gold';

-- 3. Retrieve all columns for the Sales Fact table
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales'
  AND TABLE_SCHEMA = 'gold';