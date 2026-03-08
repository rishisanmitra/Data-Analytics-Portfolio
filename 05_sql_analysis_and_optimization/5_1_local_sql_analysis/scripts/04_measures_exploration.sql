USE DataWarehouse;
GO

-- 1. Find Total Sales (Revenue)
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;

-- 2. Find Total Quantity Sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;

-- 3. Find Average Price per Item
SELECT AVG(price) AS avg_price FROM gold.fact_sales;

-- 4. Find Total Number of Orders (and unique orders)
SELECT COUNT(order_number) AS total_order_rows FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_unique_orders FROM gold.fact_sales;

-- 5. Find Total Number of Products in Catalog
SELECT COUNT(product_name) AS total_products FROM gold.dim_products;

-- 6. Find Total Number of Customers in System
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- 7. Find Total Customers who have actually placed an order
SELECT COUNT(DISTINCT customer_key) AS active_customers FROM gold.fact_sales;

-- =============================================================================
-- Executive Summary Report
-- =============================================================================
-- This query combines all key metrics into a single table for reporting.

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;