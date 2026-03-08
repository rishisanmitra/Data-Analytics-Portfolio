{{ config(materialized='view') }}

WITH raw_prd AS (
    SELECT * FROM {{ source('snowflake_raw', 'crm_prd_info') }}
)

SELECT
    prd_id AS product_id,
    -- Replicating your Silver ETL logic to create the category ID
    REPLACE(LEFT(prd_key, 13), 'PRD-', 'C') || '_' || SUBSTRING(prd_key, 15, 2) AS cat_id,
    prd_key AS product_key,
    prd_nm AS product_name,
    prd_cost AS cost,
    prd_line AS product_line,
    TO_DATE(prd_start_dt, 'YYYY-MM-DD') AS start_date,
    CASE 
        WHEN prd_end_dt = '' THEN NULL 
        ELSE TO_DATE(prd_end_dt, 'YYYY-MM-DD') 
    END AS end_date
FROM raw_prd