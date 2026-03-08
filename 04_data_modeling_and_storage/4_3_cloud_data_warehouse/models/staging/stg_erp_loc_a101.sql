{{ config(materialized='view') }}

WITH raw_loc AS (
    SELECT * FROM {{ source('snowflake_raw', 'erp_loc_a101') }}
)

SELECT
    -- Strip the hyphen to align with CRM customer_key format
    REPLACE(cid, '-', '') AS customer_key,
    cntry AS country
FROM raw_loc