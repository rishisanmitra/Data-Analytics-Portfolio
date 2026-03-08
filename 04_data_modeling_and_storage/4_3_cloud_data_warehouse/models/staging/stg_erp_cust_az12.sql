{{ config(materialized='view') }}

WITH raw_az12 AS (
    SELECT * FROM {{ source('snowflake_raw', 'erp_cust_az12') }}
)

SELECT
    -- Strip 'NAS' prefix to align with CRM customer_key format
    REPLACE(cid, 'NAS', '') AS customer_key,
    TO_DATE(bdate, 'YYYY-MM-DD') AS birth_date,
    gen AS gender
FROM raw_az12