USE DataWarehouse;
GO

-- 1. Running Total of Sales Over Time
-- This shows the "Lifetime Revenue" growth month-by-month.
SELECT
    order_date,
    monthly_sales,
    SUM(monthly_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT 
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS monthly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t;

-- 2. 3-Month Moving Average of Sales
-- This "smooths out" monthly fluctuations to see the underlying trend.

SELECT
    order_date,
    monthly_sales,
    AVG(monthly_sales) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_avg
FROM (
    SELECT 
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS monthly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t;