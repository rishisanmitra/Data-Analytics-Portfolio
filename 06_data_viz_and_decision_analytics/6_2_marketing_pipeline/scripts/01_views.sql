USE OlistMarketingDB;
GO

-- VIEW 1: Channel-Level Revenue Reality Check
CREATE OR ALTER VIEW vw_channel_revenue AS
SELECT    
    mql.origin AS acquisition_channel,    
    COUNT(DISTINCT cd.seller_id) AS sellers_acquired,    
    COUNT(DISTINCT o.order_id) AS total_orders,    
    SUM(TRY_CAST(oi.price AS FLOAT)) AS gross_revenue,    
    SUM(TRY_CAST(oi.freight_value AS FLOAT)) AS total_freight,    
    SUM(TRY_CAST(oi.price AS FLOAT)) - SUM(TRY_CAST(oi.freight_value AS FLOAT)) AS net_revenue,    
    (SUM(TRY_CAST(oi.price AS FLOAT)) - SUM(TRY_CAST(oi.freight_value AS FLOAT))) / NULLIF(COUNT(DISTINCT cd.seller_id), 0) AS net_revenue_per_seller,    
    AVG(TRY_CAST(r.review_score AS FLOAT)) AS avg_review_score,    
    SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS cancellations,    
    CAST(SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS cancellation_rate
FROM mql_dataset mql
INNER JOIN closed_deals_dataset cd 
    ON mql.mql_id = cd.mql_id
LEFT JOIN olist_sellers_dataset s    
    ON cd.seller_id = s.seller_id
LEFT JOIN olist_order_items_dataset oi    
    ON s.seller_id = oi.seller_id
LEFT JOIN olist_orders_dataset o    
    ON oi.order_id = o.order_id
LEFT JOIN olist_order_reviews_dataset r    
    ON o.order_id = r.order_id
GROUP BY mql.origin;
GO

-- VIEW 2: The "Won Seller" Conversion Rate by Channel
CREATE OR ALTER VIEW vw_conversion_rates AS
SELECT    
    mql.origin AS acquisition_channel,    
    COUNT(DISTINCT mql.mql_id) AS total_mql,    
    COUNT(DISTINCT cd.seller_id) AS closed_deals,    
    CAST(COUNT(DISTINCT cd.seller_id) AS FLOAT) / NULLIF(COUNT(DISTINCT mql.mql_id), 0) AS mql_to_close_rate,    
    AVG(DATEDIFF(DAY, TRY_CAST(mql.first_contact_date AS DATE), TRY_CAST(cd.won_date AS DATE))) AS avg_days_to_close,    
    cd.business_type AS seller_business_type
FROM mql_dataset mql
LEFT JOIN closed_deals_dataset cd    
    ON mql.mql_id = cd.mql_id
GROUP BY mql.origin, cd.business_type;
GO

-- VIEW 3: Seller Cohort Revenue Decay (90-Day Value Cliff)
CREATE OR ALTER VIEW vw_cohort_decay AS
WITH seller_first_order AS (    
    SELECT        
        oi.seller_id,        
        MIN(TRY_CAST(o.order_purchase_timestamp AS DATE)) AS first_order_date    
    FROM olist_order_items_dataset oi    
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id    
    GROUP BY oi.seller_id
),
monthly_revenue AS (    
    SELECT        
        oi.seller_id,        
        DATEDIFF(MONTH, sfo.first_order_date, TRY_CAST(o.order_purchase_timestamp AS DATE)) AS months_since_first_order,        
        SUM(TRY_CAST(oi.price AS FLOAT)) AS monthly_revenue    
    FROM olist_order_items_dataset oi    
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id    
    JOIN seller_first_order sfo ON oi.seller_id = sfo.seller_id    
    GROUP BY 
        oi.seller_id,        
        DATEDIFF(MONTH, sfo.first_order_date, TRY_CAST(o.order_purchase_timestamp AS DATE))
)
SELECT    
    months_since_first_order,    
    COUNT(DISTINCT seller_id) AS active_sellers,    
    AVG(monthly_revenue) AS avg_revenue_per_seller
FROM monthly_revenue
WHERE months_since_first_order BETWEEN 0 AND 12
GROUP BY months_since_first_order;
GO

-- VIEW 4: Delivery Performance vs. Revenue by Category
CREATE OR ALTER VIEW vw_delivery_performance AS
SELECT    
    t.product_category_name_english AS category,    
    COUNT(DISTINCT o.order_id) AS total_orders,    
    AVG(CAST(DATEDIFF(DAY, TRY_CAST(o.order_purchase_timestamp AS DATE), TRY_CAST(o.order_delivered_customer_date AS DATE)) AS FLOAT)) AS avg_delivery_days,    
    AVG(CAST(DATEDIFF(DAY, TRY_CAST(o.order_purchase_timestamp AS DATE), TRY_CAST(o.order_estimated_delivery_date AS DATE)) AS FLOAT)) AS avg_estimated_days,    
    AVG(TRY_CAST(r.review_score AS FLOAT)) AS avg_review_score,    
    SUM(TRY_CAST(oi.price AS FLOAT)) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
LEFT JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY t.product_category_name_english;
GO