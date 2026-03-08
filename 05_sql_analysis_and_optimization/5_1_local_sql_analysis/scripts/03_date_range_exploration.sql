USE DataWarehouse;
GO

-- 1. Determine the Order Date Range
-- Identifying the boundaries of our sales history.
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS total_range_months
FROM gold.fact_sales;

-- 2. Determine the Customer Age Range
-- Calculating the age of the oldest and youngest customers as of today.
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate) , GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate) , GETDATE()) AS youngest_age
FROM gold.dim_customers;