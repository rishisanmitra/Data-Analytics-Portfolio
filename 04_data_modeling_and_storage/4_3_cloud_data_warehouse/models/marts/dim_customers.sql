{{ config(materialized='table') }}

WITH customers AS (
    SELECT * FROM {{ ref('stg_crm_cust_info') }}
),
erp_cust AS (
    SELECT * FROM {{ ref('stg_erp_cust_az12') }}
),
erp_loc AS (
    SELECT * FROM {{ ref('stg_erp_loc_a101') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY c.customer_id) AS customer_key,
    c.customer_id,
    c.customer_key AS customer_number,
    c.first_name,
    c.last_name,
    l.country,
    c.marital_status,
    CASE 
        WHEN c.gender != 'n/a' THEN c.gender
        ELSE COALESCE(e.gender, 'n/a') 
    END AS gender,
    e.birth_date AS birthdate,
    c.create_date
FROM customers c
LEFT JOIN erp_cust e 
    ON c.customer_key = e.customer_key
LEFT JOIN erp_loc l 
    ON c.customer_key = l.customer_key