{{ config(materialized='view') }}

WITH raw_sales AS (
    SELECT * FROM {{ source('snowflake_raw', 'crm_sales_details') }}
)

SELECT
    sls_ord_num AS order_number,
    sls_prd_key AS product_key,
    sls_cust_id AS customer_id,
    -- Convert string dates to actual Snowflake dates
    TO_DATE(sls_order_dt, 'YYYYMMDD') AS order_date,
    TO_DATE(sls_ship_dt, 'YYYYMMDD') AS shipping_date,
    TO_DATE(sls_due_dt, 'YYYYMMDD') AS due_date,
    sls_sales AS sales_amount,
    sls_quantity AS quantity,
    sls_price AS unit_price
FROM raw_sales
WHERE sls_ord_num IS NOT NULL