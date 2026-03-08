{{ config(materialized='table') }}

WITH products AS (
    SELECT * FROM {{ ref('stg_crm_prd_info') }}
),
categories AS (
    SELECT * FROM {{ ref('stg_erp_px_cat_g1v2') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY p.start_date, p.product_key) AS product_key,
    p.product_id,
    p.product_key AS product_number,
    p.product_name,
    p.cat_id AS category_id,
    c.category,
    c.subcategory,
    c.maintenance_flag AS maintenance,
    p.cost,
    p.product_line,
    p.start_date,
    -- Replaced the WHERE clause with a business-friendly status flag
    CASE 
        WHEN p.end_date IS NULL THEN 'Active' 
        ELSE 'Inactive' 
    END AS current_status
FROM products p
LEFT JOIN categories c 
    ON p.cat_id = c.category_id