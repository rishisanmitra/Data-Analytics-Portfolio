USE DataWarehouse;
GO

-- 1. Find Total Customers by Countries
-- Which market has our largest customer footprint?
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- 2. Find Total Customers by Gender
-- Understanding the demographic split of our customer base.
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- 3. Find Total Products by Category
-- How diverse is our inventory across different product lines?
SELECT
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- 4. Average Costs by Category
-- Identifying which categories require the most investment in stock.
SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- 5. Total Revenue by Category
-- Which category is the primary financial driver for the business?
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 6. Total Revenue by Customer (Top Spenders)
-- Identifying high-value individuals.
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- 7. Distribution of Sold Items Across Countries
-- Where is our physical product volume highest?
SELECT
    c.country,
    SUM(f.quantity) AS total_quantity_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_quantity_sold DESC;