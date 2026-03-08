USE DataWarehouse;
GO

-- 1. Explore Geographies
-- Retrieve a unique list of countries where customers are located.
SELECT DISTINCT 
    country 
FROM gold.dim_customers
ORDER BY country;

-- 2. Explore Product Categories
-- Retrieve unique categories and subcategories.
SELECT DISTINCT 
    category, 
    subcategory
FROM gold.dim_products
ORDER BY category, subcategory;

-- 3. Detailed Product Mix
-- View the full hierarchy: Category -> Subcategory -> Product Name.
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;