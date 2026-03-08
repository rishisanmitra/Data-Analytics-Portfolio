USE DataWarehouse;
GO

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH product_metrics AS (
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        SUM(f.sales_amount) AS total_sales,
        SUM(f.quantity) AS total_quantity,
        COUNT(DISTINCT f.order_number) AS total_orders,
        COUNT(DISTINCT f.customer_key) AS unique_customers,
        MAX(f.order_date) AS last_sale_date,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS product_lifespan_months
    FROM gold.dim_products p
    LEFT JOIN gold.fact_sales f
        ON p.product_key = f.product_key
    GROUP BY p.product_key, p.product_name, p.category, p.subcategory, p.cost
)
SELECT
    *,
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS performance_segment,
    ROUND(total_sales / NULLIF(total_quantity, 0), 2) AS avg_selling_price,
    DATEDIFF(month, last_sale_date, GETDATE()) AS months_since_last_sale
FROM product_metrics;
GO