{{ config(materialized='table') }}

WITH sales AS (
    SELECT * FROM {{ ref('stg_sales_details') }}
),
products AS (
    SELECT * FROM {{ ref('dim_products') }}
),
customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
)

SELECT
    s.order_number,
    p.product_key,
    c.customer_key,
    s.order_date,
    s.shipping_date,
    s.due_date,
    s.sales_amount,
    s.quantity,
    s.unit_price AS price
FROM sales s
LEFT JOIN products p 
    ON s.product_key = p.product_number
LEFT JOIN customers c 
    ON s.customer_id = c.customer_id