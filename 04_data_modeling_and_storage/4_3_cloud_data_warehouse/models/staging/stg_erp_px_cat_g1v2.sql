{{ config(materialized='view') }}

WITH raw_cat AS (
    SELECT * FROM {{ source('snowflake_raw', 'erp_px_cat_g1v2') }}
)

SELECT
    id AS category_id,
    cat AS category,
    subcat AS subcategory,
    maintenance AS maintenance_flag
FROM raw_cat