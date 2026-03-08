USE DataWarehouse;
GO

-- 1. Yearly Sales Performance
-- How does revenue compare across the 4 years of data?
SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- 2. Monthly Sales Trends (Seasonality)
-- Are there specific months where sales consistently spike?
SELECT
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
GROUP BY MONTH(order_date)
ORDER BY order_month;

-- 3. Detailed Month-over-Month View
-- Using DATETRUNC (available in SQL Server 2022+) for a continuous timeline.
-- If your version is older, we use YEAR() and MONTH() combined.
SELECT
    DATETRUNC(month, order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
GROUP BY DATETRUNC(month, order_date)
ORDER BY order_month;