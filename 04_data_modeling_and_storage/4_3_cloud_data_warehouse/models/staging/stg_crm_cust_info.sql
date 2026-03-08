{{ config(materialized='view') }}

WITH raw_cust AS (
    SELECT * FROM {{ source('snowflake_raw', 'crm_cust_info') }}
)

SELECT
    cst_id AS customer_id,
    cst_key AS customer_key,
    cst_firstname AS first_name,
    cst_lastname AS last_name,
    cst_marital_status AS marital_status,
    cst_gndr AS gender,
    TO_DATE(cst_create_date, 'YYYY-MM-DD') AS create_date
FROM raw_cust